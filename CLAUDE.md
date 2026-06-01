# Claude Code — Project Setup

## Required Plugins

This project uses two HashiCorp plugins for Terraform code generation and compliance checking.
They are declared in `.claude/settings.json` and are loaded automatically, but the HashiCorp
marketplace must be registered in your **global** Claude settings first.

### 1. Register the HashiCorp marketplace

Add the following to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "hashicorp": {
      "source": {
        "source": "github",
        "repo": "hashicorp/agent-skills"
      }
    }
  }
}
```

### 2. Install the plugins

Open Claude Code and go to **Manage Plugins**, then install:

- `terraform-code-generation` — HashiCorp marketplace
- `terraform-module-generation` — HashiCorp marketplace

### 3. Pull the MCP server image

Both plugins rely on a Docker-based MCP server. Pull it once:

```bash
docker pull hashicorp/terraform-mcp-server
```

After these three steps the plugins will activate automatically whenever you open this project.
