# Azure Service Bus + Container Apps Jobs
### Event-Driven, Serverless, Auto-Scaling Message Processing on Azure

![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

---

## 📌 Overview

This project demonstrates a **production-grade, event-driven architecture** on Azure using **Azure Service Bus** as a message broker and **Azure Container Apps Jobs** as a serverless message processor.

The system automatically scales from **zero to N replicas** based on queue depth — meaning **you pay nothing when there are no messages**, and the system handles spikes automatically without any manual intervention.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      Azure Cloud                        │
│                                                         │
│   Producer          Queue              Processor        │
│  (any client)  →  📬 Service Bus  →  ⚙️ Container      │
│                    (order-queue)       Apps Job         │
│                         ↑                  ↑            │
│                    📊 KEDA            🐳 Docker         │
│                  (auto-scaler)         Image            │
│                                         ↑              │
│                                   📦 Azure ACR         │
│                                  (image registry)      │
│                                                         │
│   📋 Log Analytics Workspace  (observability)          │
└─────────────────────────────────────────────────────────┘
```

### How It Works

1. A **message is published** to the Azure Service Bus queue
2. **KEDA** continuously monitors the queue depth
3. When messages are detected, KEDA **triggers a Container Apps Job**
4. The job **pulls the Docker image** from ACR and processes the messages
5. Once all messages are processed, the job **shuts down automatically**
6. When the queue is empty → **zero running instances, zero cost** 💰

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Azure Service Bus** | Message broker & queue management |
| **Azure Container Apps Jobs** | Serverless, event-driven job execution |
| **KEDA** | Kubernetes-based event-driven autoscaling |
| **Azure Container Registry (ACR)** | Private Docker image registry |
| **Azure Log Analytics** | Centralized logging & observability |
| **Terraform** | Infrastructure as Code (IaC) |
| **GitHub Actions** | CI/CD pipeline automation |
| **Docker** | Application containerization |
| **Python** | Message processing application |

---

## 📁 Project Structure

```
azure-servicebus-demo/
│
├── 📁 app/
│   ├── app.py              # Message processing logic
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Container image definition
│
├── 📁 infra/
│   ├── main.tf             # Azure resource definitions
│   ├── variables.tf        # Input variables
│   └── outputs.tf          # Output values (connection strings, etc.)
│
├── 📁 .github/workflows/
│   └── deploy.yml          # CI/CD pipeline (Terraform + Docker + Deploy)
│
├── .gitignore
└── README.md
```

---

## ☁️ Azure Resources

All infrastructure is managed as code via **Terraform** with remote state stored in **Azure Blob Storage**.

| Resource | Name | Purpose |
|---|---|---|
| Resource Group | `rg-eventdriven-demo` | Logical container for all resources |
| Service Bus Namespace | `sb-eventdriven-demo` | Message broker namespace |
| Service Bus Queue | `order-processing-queue` | Incoming message queue |
| Container Registry | `acreventdrivendemo` | Docker image storage |
| Container Apps Environment | `cae-eventdriven-demo` | Runtime environment for jobs |
| Log Analytics Workspace | `law-eventdriven-demo` | Logging & monitoring |
| Storage Account | `tfstateeventdriven` | Terraform remote state backend |

---

## 🔄 CI/CD Pipeline

Every push to the `main` branch triggers the following pipeline automatically:

```
git push origin main
        │
        ▼
┌─────────────────────┐
│  1. 🏗️  Terraform   │  → Provisions / updates Azure infrastructure
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│  2. 🐳  Docker      │  → Builds image, pushes to ACR
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│  3. 🚀  Deploy      │  → Creates/updates Container Apps Job
└─────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Docker](https://docs.docker.com/get-docker/)
- [GitHub CLI](https://cli.github.com/)
- An active Azure subscription

### 1. Clone the Repository

```bash
git clone https://github.com/aykutkaann/azure-servicebus-demo.git
cd azure-servicebus-demo
```

### 2. Authenticate with Azure

```bash
az login
```

### 3. Create Terraform Remote State Storage

```bash
az storage account create \
  --name tfstateeventdriven \
  --resource-group rg-eventdriven-demo \
  --location eastus \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name tfstateeventdriven
```

### 4. Configure GitHub Secrets

| Secret | Description |
|---|---|
| `AZURE_CREDENTIALS` | Azure Service Principal JSON |
| `ACR_NAME` | Azure Container Registry name |
| `SERVICEBUS_CONNECTION_STRING` | Service Bus primary connection string |
| `AZURE_STORAGE_KEY` | Storage account key for Terraform state |

```bash
# Generate Azure credentials
az ad sp create-for-rbac --name "github-actions-demo" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID> \
  --sdk-auth

# Set GitHub secrets
gh secret set AZURE_CREDENTIALS
gh secret set ACR_NAME --body "acreventdrivendemo"
gh secret set SERVICEBUS_CONNECTION_STRING
gh secret set AZURE_STORAGE_KEY
```

### 5. Deploy

```bash
git push origin main
# GitHub Actions handles the rest automatically ✅
```

---

## 🧪 Testing

### Send a Test Message via Azure Portal

1. Navigate to **Service Bus** → `sb-eventdriven-demo`
2. Go to **Queues** → `order-processing-queue`
3. Open **Service Bus Explorer** → **Send**
4. Set Content Type to `application/json` and send:

```json
{
  "orderId": "001",
  "product": "laptop",
  "quantity": 1
}
```

### Verify Job Execution

```bash
az containerapp job execution list \
  --name job-message-processor \
  --resource-group rg-eventdriven-demo \
  --output table
```

Expected output:
```
Name                          StartTime                  Status
job-message-processor-xxxxx   2026-03-08T14:37:50+00:00  Succeeded
```

### Check Queue is Empty

```bash
az servicebus queue show \
  --resource-group rg-eventdriven-demo \
  --namespace-name sb-eventdriven-demo \
  --name order-processing-queue \
  --query "countDetails.activeMessageCount" \
  --output tsv
# Expected: 0 ✅
```

---

## ⚡ Key Design Decisions

### Why Container Apps Jobs instead of a always-on service?
Container Apps Jobs are **ephemeral** — they spin up to process messages and shut down immediately after. This means **zero cost when idle**, which is ideal for batch/event-driven workloads.

### Why KEDA?
KEDA (Kubernetes Event-Driven Autoscaling) is built into Azure Container Apps. It natively supports Azure Service Bus as a trigger, allowing the system to scale from 0 to N job replicas based on the number of messages in the queue.

### Why Terraform Remote State?
Storing Terraform state in Azure Blob Storage ensures that both **local development** and **GitHub Actions CI/CD** share the same state file — preventing resource duplication conflicts.

---

## 📊 Cost Profile

| Scenario | Cost |
|---|---|
| Queue empty, no messages | **~$0.00** |
| Processing 1,000 messages/day | **< $1.00** |
| Processing 1,000,000 messages/day | **Pay per execution** |

> This architecture is designed to be **extremely cost-efficient** for intermittent workloads.

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<p align="center">Built with ❤️ using Azure, Terraform & GitHub Actions</p>
