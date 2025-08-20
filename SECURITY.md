# Security Policy

The security of this project is a top priority. We take all security vulnerabilities seriously.

## Supported Versions

We provide security updates for the latest major version of each solution. Please ensure you are using the most up-to-date version.

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it to us privately. **Do not open a public issue.**

Please send an email to `security@example.com` with the following information:

-   A description of the vulnerability.
-   The solution and version affected.
-   Steps to reproduce the vulnerability.
-   Any potential impact of the vulnerability.

We will acknowledge your report within 48 hours and will work with you to address the issue. We will make a public announcement once the vulnerability has been patched.

## Security Best Practices

-   **Authentication:** Always use strong, unique passwords for your WebDAV server and S3-compatible endpoints. We recommend using the authentication methods provided with each solution, such as API keys, OAuth 2.0, or LDAP integration.
-   **Encryption:** Use HTTPS to encrypt data in transit. Many solutions in this repository include automatic SSL/TLS via Let's Encrypt. For data at rest, ensure your backend storage provider supports encryption.
-   **Environment Variables:** Do not hardcode secrets in your `docker-compose.yml` files. Use a `.env` file or a secret management system to handle sensitive information.
-   **Network Exposure:** Do not expose services to the public internet unless necessary. Use a firewall or reverse proxy to restrict access to your services.
-   **Regular Updates:** Keep your Docker images, operating system, and all components of your solution up to date with the latest security patches.

By following these best practices, you can significantly improve the security of your deployment.
