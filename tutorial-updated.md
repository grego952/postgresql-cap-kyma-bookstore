---
title: Set Up PostgreSQL Service and Development Environment for CAP Bookstore Application
description: Learn how to set up PostgreSQL BTP service, configure Kyma environment, and prepare for CAP application development and deployment.
keywords: cap, postgresql, kyma, sap-btp
parser: v2
auto_validation: true
time: 30
tags: [ tutorial>beginner, software-product>sap-business-technology-platform, software-product>sap-btp--kyma-runtime, tutorial>sap-cap, topic>cloud]
primary_tag: software-product>sap-btp--kyma-runtime
author_name: Grzegorz Karaluch
author_profile: https://github.com/grego952
---

# Set Up PostgreSQL Service and Development Environment for CAP Bookstore Application

## Introduction

Learn how to set up your development environment for building a complete bookstore application using SAP CAP framework with PostgreSQL BTP integration. This tutorial guides you through adding PostgreSQL entitlements, deploying a PostgreSQL service instance, and configuring connectivity from your Kyma runtime environment.

## You will learn

- How to add PostgreSQL entitlements to your SAP BTP, Kyma environment
- How to deploy and configure PostgreSQL service instance in Kyma
- How to set up network connectivity between Kyma cluster and PostgreSQL
- How to prepare your development environment with the CAP bookstore template

## Prerequisites

- [SAP BTP, Kyma runtime enabled](cp-kyma-getting-started)
- Enough quota to add the PostgreSQL entitlements to your environment
- [kubectl installed](https://kubernetes.io/docs/tasks/tools/)
- [Docker Desktop installed](https://www.docker.com/products/docker-desktop/)
- [Node.js 18+ installed](https://nodejs.org/)
- [psql client installed](https://www.postgresql.org/download/) for testing database connections

### Understand PostgreSQL entitlements

Before we start, let's understand what PostgreSQL plans are available. For this tutorial, we'll use the **free** plan which is perfect for learning.

Available PostgreSQL service options:

- **Standard (2 GB memory blocks)** - 1 CPU Core with 2GB RAM. Good for development and small production apps.
- **Premium (4 GB memory blocks)** - 1 CPU Core with 4GB RAM. Better performance for medium to large apps.
- **Storage (5GB storage)** - Basic storage for your database.
- **Storage_HA (5GB storage)** - Storage with high-availability features.

> **What we'll use:** For this tutorial, the **free** plan (with 1GB RAM and 0.5 CPU) is completely sufficient and won't consume your quota unnecessarily. 

### Add PostgreSQL entitlements to your account

First, we need to enable PostgreSQL service for your account:

1. In your SAP BTP subaccount, go to **Entitlements** and choose **Edit**.

2. Choose **Add Service Plans** and search for **PostgreSQL, Hyperscaler Option**.

3. Select **free**, and choose **Add 1 Service Plan**.

4. Choose **Save**.

You are now ready to deploy a PostgreSQL instance in your subaccount.

> For the sake of this tutorial, the chosen entitlement units are sufficient but, when doing your sizing and configuration, consider the necessary amount of entitlement units (2GB/4GB memory blocks and 5GB storage blocks) to support your architecture. Depending on the hyperscaler, configurations can consume different numbers of entitlement units. See [Sizing](https://help.sap.com/docs/postgresql-on-sap-btp/postgresql-on-sap-btp-hyperscaler-option/sizing?locale=en-US) and [Service Plans and Entitlements](https://help.sap.com/docs/postgresql-on-sap-btp/postgresql-on-sap-btp-hyperscaler-option/service-plans-and-entitlements?locale=en-US). 

### Get the bookstore project starter

Now let's set up our bookstore application using the provided starter project:

1. Clone or download the starter project:

    ```bash
    git clone https://github.com/your-repository/bookstore-starter
    cd bookstore-starter
    ```

    > **Note:** Alternatively, you can use the provided `bookstore-starter` directory from this tutorial.

2. Install dependencies:

    ```bash
    npm install
    ```

3. Test the basic setup with SQLite (for local development):

    ```bash
    npm start
    ```
    
    or use the VS Code task:
    
    ```
    cds watch
    ```
    
    > At this stage, your application is running with SQLite for local development. You should be able to access it at http://localhost:4004. Later, we'll connect it to PostgreSQL on SAP BTP.

4. Explore the project structure:
   - `/db/schema.cds` - The data model for books, authors, and orders
   - `/srv/services.cds` - The service definitions (CatalogService and AdminService)
   - `/app/index.html` - The simple frontend interface
   - `/server.js` - Custom server configuration with PostgreSQL integration

### Deploy PostgreSQL in Kyma environment

Now we'll create the actual PostgreSQL database that your application will use:

1. In your SAP BTP subaccount, go to the **Kyma Environment** section and choose **Link to dashboard** to open the Kyma Dashboard.
2. Go to **Namespaces** and choose **Create**.
3. Enter `cap-bookstore` as the **Name**, check the box for **Sidecar Injection**, and choose **Create**.
4. Go to **Service Management** → **Service Instances** and choose **Create**.
5. Fill in these details and choose **Create**:

     - **Name:** `bookstore-postgres`
     - **Offering Name:** `postgresql-db`
     - **Plan Name:** `free`

    > This creates your actual PostgreSQL database in the cloud. The system will automatically provision the database server, configure it, and make it ready for use.
    >
    > This process may take several minutes. You'll know it's ready when the status changes to `Provisioned`.

6. Go to **Service Management** → **Service Bindings**, and choose **Create**.
7. Fill in these details and choose **Create**:
     - **Name:** `bookstore-binding`
     - **Service Instance Name:** `bookstore-postgres` (select from dropdown)

    > Service bindings create secure credentials your application will use to connect to the database.

### Configure PostgreSQL connectivity for Kyma

Now we need to set up security to allow your Kyma application to connect to PostgreSQL:

1. Follow the [Get Egress IPs](https://github.com/SAP-samples/kyma-runtime-samples/tree/main/get-egress-ips) tutorial, and save the IP address you get.

    > When your application in Kyma tries to connect to external services (like PostgreSQL), it uses a specific outbound IP address. PostgreSQL needs to know this address for security purposes.

2. Go back to **Service Instances** and select `bookstore-postgres`
3. Go to **Edit** and in the **Instance Parameters** section, add this JSON, and replace with your actual IP addresses (Kyma cluster IP and your own local IP):

    ```json
    {
    "allow_access": "123.45.67.89,012.34.56.78"
    }
    ```

    > **NOTE:** In addition to your Kyma cluster's IP address, make sure to also add your own local IP (e.g., your computer's IP address). This will allow you to test the database connection from your local machine in the next step.

4. Choose **Update**.

    > You're telling PostgreSQL "only accept connections from my Kyma cluster's IP address." This is an important security measure that prevents unauthorized access to your database.

### Test the database connection

1. Go to **Configuration** → **Secrets** and choose `bookstore-binding`.
2. Go to the **Data** section and choose **Decode**.
3. Find and copy the `uri` value - it is a long string starting with `postgres://`
4. Open a terminal on your computer and run:

    ```bash
    psql "YOUR_COPIED_URI_VALUE?sslmode=require"
    ```
   
    > If successful, you'll connect to the PostgreSQL console and see a welcome message.

5. For local development, you can also run a PostgreSQL instance in Docker using the provided script:

    ```bash
    ./start-postgres.sh
    ```
   
   This will create a Docker container with PostgreSQL running on port 5432, which you can use for local development.

Congratulations! You have successfully set up your development environment.

You are now ready for the next tutorial, where you will implement the core application logic and deploy your complete bookstore application.

# Implement and Deploy CAP Bookstore Application with PostgreSQL

## Introduction

Build a complete bookstore application by implementing the data model, services, custom endpoints, and frontend interface.

## You will learn

- How to update your local application to use PostgreSQL
- How to build and containerize your CAP application
- How to deploy your application to the Kyma runtime
- How to test and troubleshoot cloud-native CAP applications

## Prerequisites

- [Set Up PostgreSQL Service and Development Environment for CAP Bookstore Application](tutorial-part1-setup.md) completed

---

### Update your application to use PostgreSQL

Now let's update your local development environment to use PostgreSQL instead of SQLite:

1. First, start your local PostgreSQL instance if you haven't already:

    ```bash
    ./start-postgres.sh
    ```
    
    > **What this script does:** This script automatically:
    > - Checks if a Docker container named `cap-bookstore-postgres` already exists
    > - Creates or starts the container with PostgreSQL 14 running inside
    > - Sets up a database named `capdb` with user `capuser` and password `cappassword`
    > - Exposes PostgreSQL on port 5432 of your local machine
    > - Prints connection details and instructions for configuring your application

2. Update your `package.json` to use PostgreSQL instead of SQLite:

    ```json
    "cds": {
      "requires": {
        "db": {
          "kind": "postgres",
          "credentials": {
            "host": "localhost",
            "port": 5432,
            "database": "capdb",
            "user": "capuser",
            "password": "cappassword",
            "ssl": false
          }
        }
      }
    }
    ```

3. Deploy your schema to the local PostgreSQL database:

    ```bash
    cds deploy
    ```
    
    > **Troubleshooting:** If you encounter errors like "Dropping elements is not supported", it means there's a conflict between your schema definition and existing tables. This can happen if:
    > - The database already has tables with a different structure
    > - A previous deployment created tables with a different schema
    > 
    > To resolve this, you can clean up the database by dropping all tables:
    > ```bash
    > psql postgresql://capuser:cappassword@localhost:5432/capdb -c "DROP TABLE IF EXISTS cds_outbox_messages, cds_model, sap_capire_bookstore_authors, sap_capire_bookstore_books, sap_capire_bookstore_customers, sap_capire_bookstore_orderitems, sap_capire_bookstore_orders CASCADE;"
    > ```
    > Then run `cds deploy` again.

4. Start the application:

    ```bash
    cds watch
    ```

5. Open your browser at http://localhost:4004 and test that your application works with PostgreSQL.

### Update the PostgreSQL test endpoint

The starter project contains a demo endpoint in `server.js` that needs to be updated to work with your local PostgreSQL:

1. Open the `server.js` file and find the `/api/test-postgres` endpoint.

2. Replace the existing endpoint implementation with the updated PostgreSQL client configuration. Look for this code section:

   ```javascript
   // Custom endpoint that bypasses CAP ORM and uses direct PostgreSQL
   app.get('/api/test-postgres', async (req, res) => {
     // This will be modified during the tutorial to use PostgreSQL
     // when the user switches from SQLite to PostgreSQL
     
     // For SQLite demo, just return some mock data
     res.json({
       success: true,
       message: "Demo mode - PostgreSQL not yet configured",
       books: [
         { 
           title: "Sample Book 1", 
           author: "Sample Author", 
           price: "29.99", 
           currency_code: "EUR" 
         }
       ],
       connection_info: {
         host: "localhost",
         database: "demo",
         ssl_mode: "disabled"
       }
     });
   });
   ```

   And replace it with this updated implementation that connects to PostgreSQL:

   ```javascript
   // Custom endpoint that bypasses CAP ORM and uses direct PostgreSQL
   app.get('/api/test-postgres', async (req, res) => {
     // For local development with Docker PostgreSQL
     const isLocalDev = process.env.NODE_ENV !== 'production';
     
     const client = new Client(isLocalDev ? {
       host: 'localhost',
       port: 5432,
       database: 'capdb',
       user: 'capuser',
       password: 'cappassword',
       ssl: false
     } : {
       connectionString: process.env.POSTGRES_URI,
       ssl: { 
         rejectUnauthorized: false,
         require: true
       }
     });
     
     try {
       await client.connect();
       console.log('✅ PostgreSQL connection successful');
       
       const result = await client.query(`
         SELECT 
           title, 
           author, 
           price, 
           currency_code 
         FROM sap_capire_bookstore_books 
         LIMIT 3
       `);
       
       await client.end();
       
       res.json({
         success: true,
         message: "🎯 PostgreSQL Integration Working!",
         books: result.rows,
         connection_info: {
           host: isLocalDev ? 'localhost' : process.env.POSTGRES_HOST,
           database: isLocalDev ? 'capdb' : process.env.POSTGRES_DB,
           ssl_mode: isLocalDev ? "disabled" : "require"
         }
       });
     } catch (error) {
       if (client) await client.end();
       console.error('❌ PostgreSQL connection failed:', error.message);
       res.status(500).json({
         success: false,
         error: error.message
       });
     }
   });
   ```

3. Save the file and restart the application.

4. Test the PostgreSQL connection by clicking the "Test PostgreSQL Connection" button in the UI or by accessing the `/api/test-postgres` endpoint directly.

### Prepare your application for deployment

Now let's prepare your application for deployment to Kyma:

1. Update your Docker Hub username in the `build.sh` script:

    ```bash
    # Edit build.sh
    REGISTRY="your-docker-username"
    ```

2. Update your Kyma domain in the Kubernetes configuration files:

    ```bash
    # Get your Kyma domain
    kubectl get gateway -n kyma-system kyma-gateway -o jsonpath='{.spec.servers[0].hosts[0]}' | sed 's/^\*\.//'
    ```

3. Edit `k8s/apirule.yaml` and `k8s/virtualservice.yaml` to use your domain:

    ```yaml
    # In apirule.yaml
    spec:
      host: bookstore-cap.YOUR-CLUSTER-DOMAIN
    
    # In virtualservice.yaml
    spec:
      hosts:
        - "bookstore-cap.YOUR-CLUSTER-DOMAIN"
    ```

4. Build the Docker image:

    ```bash
    ./build.sh v1
    ```

    > This creates a multi-architecture Docker image (both for Intel/AMD64 and ARM64/Apple Silicon) and pushes it to your registry.

### Deploy to Kyma

Now let's deploy your application to the Kyma runtime:

1. **Deploy the application:**

    ```bash
    ./deploy.sh cap-bookstore v1
    ```

    > This script creates the namespace, applies all Kubernetes manifests, and waits for the deployment to be ready.

2. **Initialize database schema:**

    ```bash
    # Get the name of the running pod
    POD_NAME=$(kubectl get pods -n cap-bookstore -l app=bookstore -o jsonpath='{.items[0].metadata.name}')
    
    # Deploy schema using CAP
    kubectl exec $POD_NAME -n cap-bookstore -- npm run deploy
    ```

### Test your complete application

Now let's verify everything is working correctly.

1. **Get your application URL:**

    ```bash
    kubectl get apirule -n cap-bookstore
    ```

    > This command shows the public URL where your application is available.

2. **Test the frontend:** 
   
   Open your browser and navigate to your application URL. You should see:
   - Your bookstore interface
   - PostgreSQL connection test button  
   - Books displayed in a responsive layout

3. **Test the key API endpoints:**

    ```bash
    # Test PostgreSQL connectivity
    curl "https://bookstore-cap.YOUR-CLUSTER-DOMAIN/api/test-postgres"
    
    # Test OData metadata
    curl "https://bookstore-cap.YOUR-CLUSTER-DOMAIN/odata/v4/catalog/\$metadata"
    
    # Test health endpoint  
    curl "https://bookstore-cap.YOUR-CLUSTER-DOMAIN/health"
    ```

4. **Check the logs for any issues:**

    ```bash
    kubectl logs -f deployment/bookstore-deployment -n cap-bookstore
    ```

## Summary

Congratulations! You have successfully built and deployed a complete SAP CAP application using PostgreSQL and SAP BTP, Kyma runtime.

In this tutorial, you've learned:

1. How to update a CAP application to use PostgreSQL both locally and in the cloud
2. How to containerize your application and deploy it to Kyma runtime
3. How to test and troubleshoot your deployed application

You now have a fully functional bookstore application running on SAP BTP with PostgreSQL as the database.

### Next Steps

To further enhance your application, consider:

- Adding authentication and authorization
- Implementing custom business logic in your service handlers
- Enhancing the frontend with a modern UI framework like SAP UI5 or React
- Adding automated testing and CI/CD pipelines