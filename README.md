# ALB + Lambda : Plug a Lambda Function into a Legacy Application Without Changing a Single Line of Code

This repository contains the Terraform code to implement the architecture described in the article :
**[How to Plug a Lambda Function into a Legacy Application Without Changing a Single Line of Code](#)**


## What This Code Does

This Terraform code wires together an existing Application Load Balancer, an existing EC2 instance, and an existing Lambda function to implement a progressive migration pattern :

- All general traffic → forwarded to the EC2 legacy application (default behavior, unchanged)
- Traffic matching `/lambda` → intercepted by the ALB and forwarded to the Lambda function

No changes to the legacy application. No new services introduced. Just a routing rule at the load balancer level.


## Prerequisites

The following AWS resources must already exist in your account before applying this code :

| Resource | Description |
|---|---|
| Application Load Balancer | An existing ALB identified by its name |
| EC2 Instance | The legacy application instance, identified by its `Name` tag |
| Lambda Function | The new feature function, identified by its function name |
| VPC | The VPC where all resources are deployed |

> This code uses `data` sources to reference existing resources — it does not create or modify them.


## Module Structure

```
├── main.tf               # Root module — wires all sub-modules together
├── variables.tf          # Input variables
├── terraform.tfvars      # Your actual values (not committed to Git)
├── .gitignore
└── modules/
    ├── target_groups/    # Creates Lambda and Instance Target Groups
    │   ├── main.tf
    │   └── variables.tf
    ├── listener/         # Creates the ALB Listener and routing rule
    │   ├── main.tf
    │   └── variables.tf
    └── lambda_permission/ # Grants ALB permission to invoke Lambda
        ├── main.tf
        └── variables.tf
```


## Usage

**1. Clone the repository**

```bash
git clone https://github.com/your-username/alb-lambda-legacy-pattern.git
cd alb-lambda-legacy-pattern
```

**2. Create your `terraform.tfvars` file**

```hcl
alb_name             = "your-alb-name"
ec2_instance_name    = "your-ec2-name-tag"
lambda_function_name = "your-lambda-function-name"
vpc_id               = "vpc-xxxxxxxxxxxxxxxxx"
lambda_path          = "/lambda"
```

> Never commit `terraform.tfvars` to Git if it contains sensitive values. It is already listed in `.gitignore`.

**3. Initialize and apply**

```bash
terraform init
terraform plan
terraform apply
```


## Input Variables

| Variable | Description | Default |
|---|---|---|
| `alb_name` | Name of the existing ALB | required |
| `ec2_instance_name` | `Name` tag of the existing EC2 instance | required |
| `lambda_function_name` | Name of the existing Lambda function | required |
| `vpc_id` | VPC ID where resources are deployed | required |
| `lambda_path` | URL path to route to Lambda | `/lambda` |


## Key Design Decisions

**Why `data` sources instead of creating resources from scratch ?**
This pattern is designed to be applied against existing infrastructure without any risk of unintended changes. Using `data` sources ensures Terraform only reads existing resources, never modifies or destroys them.

**Why is Lambda Permission a separate module ?**
The `aws_lambda_permission` resource must exist before the Lambda Target Group attachment. Isolating it in its own module makes the dependency explicit and easy to manage. The `depends_on` in the root module enforces the correct apply order.

**Why `priority = 10` on the Listener Rule ?**
A lower priority number means higher evaluation priority. Setting it to `10` leaves room to add future rules with priorities between `11` and the Default Rule, without having to renumber existing rules.


## Common Mistakes

| Mistake | Consequence | Fix |
|---|---|---|
| Health checks enabled on Lambda Target Group | Lambda marked as unhealthy, no traffic routed | Set `enabled = false` in `health_check` block |
| Missing `aws_lambda_permission` | ALB gets permission denied, returns 502 | Always declare it explicitly in Terraform |
| Wrong Lambda response format | ALB returns 502 to client | Include `statusDescription` in Lambda response |
| Rule priority conflict | Lambda rule never evaluated | Check all existing rules before setting priority |


## Related Article

This repository is the companion code for the article :
**[How to Plug a Lambda Function into a Legacy Application Without Changing a Single Line of Code](#)**

The article covers :
- The full architecture and request flow
- Step-by-step console implementation
- All common pitfalls explained in detail
- ALB vs API Gateway : when to use which


## Author

**Jeancy Joachim Mukaka**
AWS Certified Solutions Architect – Associate | AWS Certified Cloud Practitioner
*[www.linkedin.com/in/jeancy-joachim-mukaka](LinkedIn)*
*[https://dev.to/jeancy](Dev.to)*
*[https://medium.com/@jeancymukaka6](Medium)*


## License

MIT License - feel free to use, adapt, and share this code with attribution.
