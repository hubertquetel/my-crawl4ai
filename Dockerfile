FROM python:3.9-slim

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome and its dependencies
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install crawl4ai
RUN pip install -U crawl4ai

# Run post-installation setup
RUN crawl4ai-setup

# Install Playwright and browsers
RUN python -m playwright install --with-deps chromium

# Copy application code
COPY . .

# Expose port 
EXPOSE 11235

# Command to run the application
CMD ["python", "app.py"]
