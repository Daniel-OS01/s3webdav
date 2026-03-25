# Nginx WebDAV to S3 Solution

This directory contains a custom solution for bridging WebDAV to S3 using Nginx.

This approach uses the Nginx WebDAV module to connect to a WebDAV server and Lua scripting (with the `lua-nginx-module`) to translate S3 API calls to WebDAV requests.

## Features

-   **Lightweight and Performant**: Built on top of Nginx, this solution is fast and has a small footprint.
-   **Highly Customizable**: Lua scripting allows for flexible and custom API translations.
-   **Authentication**: Can be integrated with Nginx's authentication mechanisms.

## Configurations

-   **Basic Setup**: A Docker Compose file with Nginx, the WebDAV module, and Lua scripting.
-   **Lua Scripts**: Example Lua scripts for S3 API compatibility.
-   **Proxy Configurations**: Nginx server block configurations for proxying to a WebDAV backend.

Detailed instructions will be provided in this directory.
