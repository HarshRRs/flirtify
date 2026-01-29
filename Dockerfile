# Use Node.js LTS (matches the version in user logs)
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Copy only the backend folder contents into /app
# This ensures that /app/index.js will exist correctly
COPY backend/package*.json ./
RUN npm install --production
COPY backend/ .

# Ensure production environment
ENV NODE_ENV=production
ENV PORT=5000

EXPOSE 5000

# Run the app
CMD [ "node", "index.js" ]
