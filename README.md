# SSL Certificate Checker

This script retrieves SSL certificate information for a list of domains, storing the output in separate directories for successful connections and errors. It also supports connecting through a proxy for specific subdomains and utilizes parallel processing for efficiency.

## Features

- Retrieves SSL certificate details including subject, issuer, and validity period.
- Supports proxy connections for designated subdomains.
- Outputs results to `output/success/` for successful connections and `output/error/` for connection errors.
- Uses parallel processing to handle multiple domains simultaneously, improving speed and efficiency.

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
   sudo cpan install IO::Socket::SSL Net::SSLeay Parallel::ForkManager
   ```

2. Ensure you have OpenSSL installed and the development headers if needed:
   - RedHat/Rockylinux:
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

### Proxy Settings

The script supports proxy connections for specific subdomains. To enable this, modify the condition within the script where `sub.example.com` appears to match the desired subdomains. Configure the `$proxy_host` and `$proxy_port` variables for your proxy server.

### Parallel Processing

The script uses parallel processing to handle multiple domains at once. You can adjust the number of parallel processes by modifying the `$max_processes` variable in the script. By default, it is set to 5. This setting can help improve speed when checking multiple domains.

## License

This project is licensed under the MIT License
