# Project AetherNet // Autonomic Security Engine

AetherNet is an Autonomous Security & Autonomic Route Remediation Engine designed to monitor, audit, and automatically heal network perimeter boundaries within AWS environments emulated via LocalStack.

## Core Features
1. **Local Gateway**: LocalStack container mapping S3, EC2, STS, IAM, and Lambda services.
2. **Autonomic Remediator**: Python engine auditing Transit Gateway (TGW) routes and automatically blocking intruder IPs via Layer 4 Network Access Control Lists (NACLs).
3. **Mock Cloud Initializer**: Wait-loop checking script that provisions the mock cloud, VPC resources, Transit Gateways, and seeds the ledger bucket.
4. **NOC Dashboard**: Cyperpunk dark-themed monitoring interface containing SVG topology maps and real-time alerts stream.

---

## Folder Layout

```text
Project AetherNet/
├── localstack-env/
│   └── docker-compose.yml       # LocalStack container services
├── automation-core/
│   ├── requirements.txt         # Dependency packages
│   └── boundary_remediator.py   # Autonomous audit and block engine
├── monitoring-dashboard/
│   ├── index.html               # Operator dashboard
│   ├── styles.css               # Cyperpunk styles sheet
│   └── app.js                   # Interactive controller script
├── initialize-mock-cloud.sh     # Emulation cloud bootstrapper
└── README.md                    # Setup documentation
```

---

## Getting Started

### 1. Launch local gateway
Navigate to the environment folder and run docker-compose:
```bash
cd localstack-env
docker-compose up -d
```

### 2. Initialize mock cloud resources
Run the initializer script at the root directory. To export mock credentials directly to your current shell session, source the file:
```bash
source initialize-mock-cloud.sh
```

### 3. Run the boundary remediator
Install dependencies and run the Python self-healing security engine:
```bash
cd automation-core
pip install -r requirements.txt
python boundary_remediator.py
```

### 4. Load the NOC Executive Dashboard
Open [monitoring-dashboard/index.html](file:///Users/user/Desktop/Project%20AetherNet/monitoring-dashboard/index.html) in your browser to interact with the network map, inject route violations, and trigger auto-healing.
