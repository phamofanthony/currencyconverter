# Use a minimal base image with no UID/GID conflicts
FROM python:3.9-alpine

# Set working directory
WORKDIR /app

# Copy app source
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose Flask port
EXPOSE 5555

# Environment vars
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

# Start Flask app
CMD ["flask", "run", "--host=0.0.0.0", "--port=5555"]
