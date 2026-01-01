# MtxDeploy

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)  
A project to set up a Matrix server using Docker, Traefik, and Synapse with full delegation and MAS authentication.

---

### Overview
This project provides a complete Matrix homeserver setup. It features:
*   **Synapse**: The reference Matrix homeserver implementation.
*   **MAS (Matrix Authentication Service)**: Modern OIDC-based authentication.
*   **Element Web**: The flagship Matrix client.
*   **Sliding Sync**: Next-generation sync for fast clients.
*   **Traefik**: Reverse proxy with automatic SSL management.
*   **Ntfy**: UnifiedPush provider for notifications.
*   **Synapse Admin**: Web GUI for server administration.

> [!NOTE]
> **Email Verification Bypass:**
> Due to internet restrictions in some regions (like Iran), the included MAS image is patched to bypass email verification. You can enter any code (e.g., `111111`) to verify the email.
>
> **Using Official MAS:**
> If you prefer the official image, edit `configs/chat_server/docker-compose.yml` and change the MAS image to:
> `image: "ghcr.io/matrix-org/matrix-authentication-service:${MAS_VERSION}"`

---

### Architecture
This project uses **Matrix Delegation** to separate the user identity domain from the service domain.

*   **User ID Domain:** `example.com` (Example: `@user:example.com`)
*   **Service Domain:** `chat.example.com` (Hosting Synapse, MAS, Element)

Clients look up `example.com` and are redirected to `chat.example.com` seamlessly.

---

### Prerequisites
*   A Linux server (Debian/Ubuntu recommended)
*   Docker & Docker Compose
*   Python 3 & `uv` (for config generation)
*   A domain name pointing to the server

---

### Installation

#### 1. Configure Environment
Enable the environment configuration and set your domain and secrets.

```bash
cp env.example.yml env.yml
nano env.yml
```

#### 2. Run Setup Script
Run the `gen_config.sh` script. This script will:
*   Generate all necessary configuration files.
*   Create the Docker network (`edge`).
*   Download Element Web.
*   Set correct permissions for data directories.

```bash
bash gen_config.sh
```

#### 3. Start Services
Navigate to the configuration directories and start the containers.

```bash
# Start Traefik (Edge Router)
cd configs/edge
docker compose up -d

# Start Matrix Services
cd ../chat_server
docker compose up -d
```

---

### Services & URLs
Assuming your main domain is `example.com`:

| Service | URL | Description |
| :--- | :--- | :--- |
| **Element Web** | `https://chat.example.com` | Web Client |
| **Synapse** | `https://chat.example.com` | Homeserver API |
| **Auth** | `https://auth.chat.example.com` | MAS Login |
| **Ntfy** | `https://ntfy.example.com` | Notifications |
| **Admin Panel** | `https://matrix-admin.example.com` | Server Management |
| **Traefik** | `https://to.chat.example.com` | Proxy Dashboard |

---

### Credits
Special thanks to [wiiz-ir](https://github.com/wiiz-ir/matrix-2-scripts) for the original scripts and inspiration.

---

### License
This project is licensed under the MIT License.
