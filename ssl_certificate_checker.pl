use strict;
use warnings;
use IO::Socket::SSL;
use Net::SSLeay;
use Parallel::ForkManager;
use File::Path qw(make_path);

# Maximum number of parallel processes
my $max_processes = 5;
my $pm = Parallel::ForkManager->new($max_processes);

# File containing the list of domains
my $filename = 'domains.txt';

# Output directories for success and error results
my $success_dir = 'output/success/';
my $error_dir = 'output/error/';

# Proxy server configuration (example)
my $proxy_host = 'proxy.example.com';
my $proxy_port = 8080;

# Create output directories if they don't exist
make_path($success_dir, $error_dir);

# Read domain list from file
open my $fh, '<', $filename or die "Cannot open file: $filename - $!\n";
my @domains = <$fh>;
close $fh;

foreach my $domain (@domains) {
    chomp $domain;
    next if $domain =~ /^\s*$/;

    my ($host, $port) = split(/:/, $domain);
    next unless $host && $port;

    $pm->start and next;  # Start a parallel process

    # Define output filename
    my $output_filename = "${host}.txt";

    # Check if proxy is needed for this domain
    my %ssl_options = ( SSL_verify_mode => SSL_VERIFY_NONE );
    if ($host =~ /^sub\.example\.com$/) {  # Modify to match specific subdomain as needed
        $ssl_options{Proxy} = "$proxy_host:$proxy_port";
        print "Connecting via proxy for: $host\n";
    } else {
        $ssl_options{PeerHost} = "$host:$port";
    }

    my $client = IO::Socket::SSL->new(%ssl_options);

    if (!$client) {
        # Save error output
        open my $err_out, '>', "$error_dir$output_filename" or die "Cannot open file: $output_filename - $!\n";
        print $err_out "Connection error: $host:$port\n";
        print $err_out "Error reason: $!\n";
        close $err_out;

        print "Error output file saved: $error_dir$output_filename\n";
        
        $pm->finish;
        next;
    }

    # Retrieve certificate information
    my $cert = $client->peer_certificate();
    my $subject = Net::SSLeay::X509_NAME_oneline(Net::SSLeay::X509_get_subject_name($cert));
    my $issuer = Net::SSLeay::X509_NAME_oneline(Net::SSLeay::X509_get_issuer_name($cert));
    my $not_before = Net::SSLeay::P_ASN1_TIME_get_isotime(Net::SSLeay::X509_get_notBefore($cert));
    my $not_after = Net::SSLeay::P_ASN1_TIME_get_isotime(Net::SSLeay::X509_get_notAfter($cert));

    $client->close();

    # Save success output
    open my $out, '>', "$success_dir$output_filename" or die "Cannot open file: $output_filename - $!\n";
    print $out "Certificate information - $host:$port\n";
    print $out "Subject: $subject\n";
    print $out "Issuer: $issuer\n";
    print $out "Valid from: $not_before\n";
    print $out "Valid until: $not_after\n";
    close $out;

    print "Success output file saved: $success_dir$output_filename\n";

    $pm->finish;  # End the parallel process
}

$pm->wait_all_children;  # Wait for all child processes to finish
