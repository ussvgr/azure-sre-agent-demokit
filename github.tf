# GitHub Repository
resource "github_repository" "main" {
  name        = var.github_repo_name
  description = "Azure SRE Agent Demo Environment"
  visibility  = "private"

  # Repository settings
  has_issues      = true
  has_discussions = false
  has_projects    = false
  has_wiki        = false

  # Auto-initialize with README
  auto_init = false

  # Delete branch on merge
  delete_branch_on_merge = true

  # Vulnerability alerts
  vulnerability_alerts = true

  # Allow merge commits
  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true
}

# Push files from a local directory to the repository
resource "null_resource" "push_files" {
  count = var.github_push_source_dir != "" ? 1 : 0

  triggers = {
    # Re-run when repository is recreated or source directory content changes
    repo_id    = github_repository.main.id
    source_dir = var.github_push_source_dir
    # Optional: trigger on file changes (use timestamp or hash)
    timestamp  = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      
      # Resolve absolute path of source directory
      SOURCE_DIR="$(cd "${abspath(var.github_push_source_dir)}" && pwd)"
      
      # Create temporary directory for git operations
      TEMP_DIR=$(mktemp -d)
      trap "rm -rf $TEMP_DIR" EXIT
      
      cd $TEMP_DIR
      
      # Copy files from source directory (including hidden files)
      cp -r "$SOURCE_DIR/." .
      rm -rf .git 2>/dev/null || true
      
      # Check if there are files to commit
      if [ -z "$(ls -A)" ]; then
        echo "Warning: No files found in source directory. Skipping push."
        exit 0
      fi
      
      # Initialize git and commit
      git init -b main
      git add -A
      git commit -m "${var.github_push_commit_message}"
      git remote add origin "https://github.com/${var.github_owner}/${var.github_repo_name}.git"
      git push -u origin main
      
      echo "Files pushed successfully!"
    EOT
  }

  depends_on = [github_repository.main]
}
