#!/bin/bash

# Function to create project structure
create_project_structure() {
    local project_name="$1"

    # Define the main project directory
    main_project_dir="MyFlaskProjects"

    # Create the main project directory if it doesn't exist
    mkdir -p "$main_project_dir"

    # Create the project directory
    project_dir="$main_project_dir/$project_name"
    mkdir -p "$project_dir"

    # Create the 'app' directory
    app_dir="$project_dir/app"
    mkdir -p "$app_dir"

    # Create '__init__.py' in 'app' directory
    touch "$app_dir/__init__.py"

    # Create 'routes.py' in 'app' directory
    touch "$app_dir/routes.py"

    # Create 'templates' directory
    templates_dir="$app_dir/templates"
    mkdir -p "$templates_dir"

    # Create 'index.html' in 'templates' directory
    cat <<EOL > "$templates_dir/index.html"
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>$project_name - Flask App</title>
        <link rel="stylesheet" href="{{ url_for('static', filename='css/bootstrap.min.css') }}">
        <!-- Add more CSS or Bootstrap CDN links as needed -->
    </head>
    <body>

        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <a class="navbar-brand" href="{{ url_for('home') }}">$project_name</a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ml-auto">
                    <li class="nav-item"><a class="nav-link" href="{{ url_for('home') }}">Home</a></li>
                    <li class="nav-item"><a class="nav-link" href="{{ url_for('about') }}">About</a></li>
                </ul>
            </div>
        </nav>

        <div class="container mt-5">
            <h1>Welcome to $project_name</h1>
            <p>This is a basic Flask app template.</p>
        </div>

        <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>

    </body>
    </html>
    EOL

    # Create 'static' directory
    static_dir="$app_dir/static"
    mkdir -p "$static_dir"

    # Create 'Dockerfile' in project directory
    touch "$project_dir/Dockerfile"

    # Create 'requirements.txt' in project directory
    touch "$project_dir/requirements.txt"

    # Create 'config.py' in project directory
    touch "$project_dir/config.py"

    # Create 'docker-compose.yml' in main project directory if it doesn't exist
    docker_compose="$main_project_dir/docker-compose.yml"
    if [ ! -f "$docker_compose" ]; then
        cat <<EOL > "$docker_compose"
        version: '3.8'

        services:
          $project_name:
            build: ./$project_name
            ports:
              - "5000:5000"
            volumes:
              - ./$project_name:/app
            environment:
              - FLASK_APP=app/routes.py
              - FLASK_ENV=development

        networks:
          default:
            driver: bridge
        EOL
    fi
}

# Check if a project name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <project_name> [-m]"
    exit 1
fi

# Process command line options
while getopts ":m" opt; do
    case $opt in
        m)
            multiple_projects=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

if [ "$multiple_projects" == "true" ]; then
    # Create multiple projects
    for project_name in "$@"; do
        create_project_structure "$project_name"
        echo "Project structure created successfully for $project_name!"
    done
else
    # Create a single project
    project_name="$1"
    create_project_structure "$project_name"
    echo "Project structure created successfully for $project_name!"
fi
