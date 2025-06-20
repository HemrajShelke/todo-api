# Todo List API Server

This project is a simple Todo List application with a Python Flask backend, an SQLite database, and a plain HTML, CSS, and JavaScript frontend.

## APIs

The following API endpoints are available:

### 1. Get All Todos

- **Endpoint:** `/todos`
- **Method:** `GET`
- **Description:** Retrieves a list of all todo items.
- **Sample Response:**
  ```json
  [
    {
      "id": 1,
      "task": "Learn about APIs",
      "completed": true
    },
    {
      "id": 2,
      "task": "Build a project",
      "completed": false
    }
  ]
  ```

### 2. Add a New Todo

- **Endpoint:** `/todos`
- **Method:** `POST`
- **Description:** Adds a new todo item to the list.
- **Request Body:**
  ```json
  {
    "task": "Write documentation"
  }
  ```
- **Sample Response:**
  ```json
  {
    "id": 3,
    "task": "Write documentation",
    "completed": false
  }
  ```

### 3. Update a Todo

- **Endpoint:** `/todos/<id>`
- **Method:** `PUT`
- **Description:** Updates an existing todo item. You can update the task or the completed status.
- **Request Body:**
  ```json
  {
    "task": "Update the documentation",
    "completed": true
  }
  ```
- **Sample Response:**
  ```json
  {
    "id": 3,
    "task": "Update the documentation",
    "completed": true
  }
  ```

### 4. Delete a Todo

- **Endpoint:** `/todos/<id>`
- **Method:** `DELETE`
- **Description:** Deletes a todo item.
- **Sample Response:** `204 No Content`

## Database

This project uses **SQLite**, a lightweight, serverless, self-contained, transactional SQL database engine. The database is integrated into the Flask application using the `Flask-SQLAlchemy` extension. The database file `todos.db` will be automatically created in the `backend` directory when the server is first started.

The `Todo` model in `app.py` defines the structure of the `todos` table in the database.

## How to Run the Server

1.  Navigate to the `backend` directory:
    ```bash
    cd backend
    ```
2.  Create a virtual environment (optional but recommended):
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
    ```
3.  Install the required packages:
    ```bash
    pip install -r requirements.txt
    ```
4.  Run the Flask application:
    ```bash
    python app.py
    ```
5.  The server will start on `http://127.0.0.1:5000`.

## How to Run the Frontend

1.  Navigate to the `frontend` directory.
2.  Open the `index.html` file in your web browser.

## How to Interact with the API

You can interact with the API using the provided frontend or by sending requests with a tool like `curl`.

**Example using `curl`:**

- **Get all todos:**
  ```bash
  curl http://127.0.0.1:5000/todos
  ```

- **Add a new todo:**
  ```bash
  curl -X POST -H "Content-Type: application/json" -d '{"task":"Test with curl"}' http://127.0.0.1:5000/todos
  ```
