# DevOps_Tech_Assessment
Assessment for Senior DevOps Engineer

# Context:
You're handed a poorly structured Terraform configuration meant to deploy 
infrastructure for multiple environments (dev, staging, prod).
Currently, it’s a single messy flat file with duplicated code and hardcoded values.

# Problem Statement:
You are given the following Terraform configuration:

# Task:

Refactor this configuration into a clean, reusable module-based structure that can 
be used across multiple environments (dev, staging, prod).

- Avoid duplication  
- Make it environment-agnostic via variables  
- Structure it into layers if possible (e.g., core infra, network, services, etc.)  
- Bonus: show how to call this module for different environments

