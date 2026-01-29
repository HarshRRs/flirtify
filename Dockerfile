# Use Node.js LTS
FROM node:18-alpine

# Set working directory to /app
WORKDIR /app

# Copy backend dependency files first for caching
COPY backend/package*.json ./

# Install production dependencies
RUN npm install --production

# Copy the rest of the backend source code
# This copies everything inside 'backend/' into '/app/'
COPY backend/ .

# Expose the port
EXPOSE 5000

# Start the application directly from the root of the backend
CMD [ "node", "index.js" ]
