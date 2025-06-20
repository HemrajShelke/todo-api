const apiUrl = 'http://127.0.0.1:5000/todos';
const todoForm = document.getElementById('todo-form');
const todoInput = document.getElementById('todo-input');
const todoList = document.getElementById('todo-list');

// Fetch and display todos
async function getTodos() {
    const response = await fetch(apiUrl);
    const todos = await response.json();
    todoList.innerHTML = '';
    todos.forEach(todo => {
        const li = document.createElement('li');
        li.dataset.id = todo.id;
        if (todo.completed) {
            li.classList.add('completed');
        }

        const span = document.createElement('span');
        span.textContent = todo.task;
        span.addEventListener('click', () => toggleComplete(todo.id, !todo.completed));

        const deleteButton = document.createElement('button');
        deleteButton.textContent = 'Delete';
        deleteButton.addEventListener('click', (e) => {
            e.stopPropagation();
            deleteTodo(todo.id);
        });

        li.appendChild(span);
        li.appendChild(deleteButton);
        todoList.appendChild(li);
    });
}

// Add a new todo
todoForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const task = todoInput.value.trim();
    if (!task) return;

    await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ task })
    });
    todoInput.value = '';
    getTodos();
});

// Toggle complete status
async function toggleComplete(id, completed) {
    await fetch(`${apiUrl}/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ completed })
    });
    getTodos();
}

// Delete a todo
async function deleteTodo(id) {
    await fetch(`${apiUrl}/${id}`, {
        method: 'DELETE'
    });
    getTodos();
}

// Initial load
getTodos();
