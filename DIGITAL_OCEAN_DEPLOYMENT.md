# Deploying GPT-Researcher to Digital Ocean

This guide will walk you through deploying the GPT-Researcher application on a Digital Ocean Droplet using Docker Compose.

## Prerequisites

- A Digital Ocean account
- Your API keys for OpenAI, Tavily, and LangChain (as required by the application)

## Step 1: Create a Digital Ocean Droplet

1. Log in to your Digital Ocean account
2. Click on "Create" and select "Droplets"
3. Choose an image: Ubuntu 22.04 LTS
4. Select a plan: Basic
   - For resource allocation, choose at least:
     - 2 GB RAM / 1 CPU
     - 50 GB SSD
5. Choose a datacenter region close to your users
6. Authentication: SSH keys (recommended) or password
7. Add your SSH key or create a new one
8. Choose a hostname (e.g., gpt-researcher)
9. Click "Create Droplet"

## Step 2: Connect to Your Droplet

Once your Droplet is created, connect to it via SSH:

```bash
ssh root@your_droplet_ip
```

## Step 3: Install Docker and Docker Compose

Update your system and install Docker:

```bash
apt update && apt upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

Install Docker Compose:

```bash
curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## Step 4: Clone the Repository

Install Git and clone the repository:

```bash
apt install git -y
git clone https://github.com/assafelovic/gpt-researcher.git
cd gpt-researcher
```

## Step 5: Configure Environment Variables

Create an environment file:

```bash
cp .env.example .env
```

Edit the `.env` file to add your API keys:

```bash
nano .env
```

Add the following variables (replace with your actual API keys):

```
OPENAI_API_KEY=your_openai_api_key
TAVILY_API_KEY=your_tavily_api_key
LANGCHAIN_API_KEY=your_langchain_api_key
NEXT_PUBLIC_GPTR_API_URL=http://your_droplet_ip:8000
```

Save and exit (Ctrl+X, then Y, then Enter).

## Step 6: Deploy with Docker Compose

Create necessary directories for volume mounts:

```bash
mkdir -p my-docs outputs logs
```

Build and start the containers:

```bash
docker-compose pull || true
docker-compose build
docker-compose up -d
```

## Step 7: Configure Firewall (Optional but Recommended)

Allow traffic to the application ports:

```bash
ufw allow 22/tcp
ufw allow 8000/tcp
ufw allow 3000/tcp
ufw enable
```

## Step 8: Access Your Application

- Backend API: `http://your_droplet_ip:8000`
- Frontend: `http://your_droplet_ip:3000`

## Managing Your Deployment

### View Logs

```bash
docker-compose logs -f
```

### Stop the Application

```bash
docker-compose down
```

### Restart the Application

```bash
docker-compose restart
```

### Update the Application

```bash
git pull
docker-compose down
docker-compose build
docker-compose up -d
```

## Setting Up a Domain Name (Optional)

1. Purchase a domain name from a domain registrar
2. Add an A record pointing to your Droplet's IP address
3. Install Nginx as a reverse proxy:

```bash
apt install nginx -y
```

4. Create an Nginx configuration file:

```bash
nano /etc/nginx/sites-available/gpt-researcher
```

5. Add the following configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

6. Enable the site and restart Nginx:

```bash
ln -s /etc/nginx/sites-available/gpt-researcher /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

7. Set up SSL with Certbot:

```bash
apt install certbot python3-certbot-nginx -y
certbot --nginx -d your-domain.com -d www.your-domain.com
```

## Troubleshooting

### Container Issues

Check container status:
```bash
docker-compose ps
```

View container logs:
```bash
docker-compose logs -f [service_name]
```

### Network Issues

Check if ports are open:
```bash
netstat -tuln | grep -E '8000|3000'
```

### Permission Issues

If you encounter permission issues with volume mounts:
```bash
chmod -R 777 my-docs outputs logs
```

## Maintenance

### Backup

Backup your data directories:
```bash
tar -czvf gpt-researcher-backup.tar.gz my-docs outputs logs .env
```

### Monitoring

Consider setting up monitoring with Digital Ocean's monitoring tools or install a monitoring solution like Prometheus and Grafana.

## Support

If you encounter any issues, refer to the [official documentation](https://docs.gptr.dev/) or open an issue on the [GitHub repository](https://github.com/assafelovic/gpt-researcher). 