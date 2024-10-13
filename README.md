# SSL Certificate Checker

This script retrieves SSL certificate information for a list of domains, storing the output in separate directories for successful connections and errors. It also supports connecting through a proxy for specific subdomains.

## Features

- Retrieves SSL certificate details including subject, issuer, and validity period.
- Supports proxy connections for designated subdomains.
- Outputs results to `output/success/` for successful connections and `output/error/` for connection errors.

## Requirements

- Perl 5
- Perl modules:
  - `IO::Socket::SSL`
  - `Net::SSLeay`
  - `Parallel::ForkManager`
  - `File::Path` (part of Perl core)

## Installation

1. Install the required Perl modules:
   ```bash
   cpan install IO::Socket::SSL Net::SSLeay Parallel::ForkManager

2. Ensure you have OpenSSL installed and the development headers if needed:
   - RedHat/CentOS:
     ```bash
     sudo yum install openssl-devel
     ```
   - Ubuntu/Debian:
     ```bash
     sudo apt-get install libssl-dev
     ```

## Usage

1. Prepare a file called `domains.txt` listing the domains and ports to check, one per line in the format:
   ```
   example.com:443
   sub.example.com:443
   ```

2. Run the script:
   ```bash
   perl ssl_certificate_checker.pl
   ```

3. Results will be saved in:
   - `output/success/` for successful connections.
   - `output/error/` for failed connections, along with error details.

## Configuration

To enable proxy for specific subdomains, modify the condition within the script where `sub.example.com` appears to match the desired subdomains. Also, configure the `$proxy_host` and `$proxy_port` variables accordingly.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

