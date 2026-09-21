<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Employee Management</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 900px; margin: 40px auto; color: #222; }
        h1 { margin-bottom: 4px; }
        .subtitle { color: #666; margin-top: 0; margin-bottom: 24px; }

        form#employeeForm {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 24px;
            background: #f5f5f5;
            padding: 16px;
            border-radius: 8px;
        }
        form#employeeForm input {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        form#employeeForm .actions {
            grid-column: span 4;
            display: flex;
            gap: 8px;
        }
        button {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        button.primary { background: #2563eb; color: white; }
        button.secondary { background: #e5e7eb; color: #111; }
        button.danger { background: #dc2626; color: white; }
        button.edit { background: #059669; color: white; }

        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 10px 12px; border-bottom: 1px solid #e5e7eb; }
        th { background: #f9fafb; }
        td.actions-col { display: flex; gap: 6px; }

        #statusMsg { margin: 10px 0; font-size: 14px; }
        #statusMsg.error { color: #dc2626; }
        #statusMsg.success { color: #059669; }
    </style>
</head>
<body>

<h1>Employee Management</h1>
<p class="subtitle">Backed by EmployeeServlet + Hibernate + PostgreSQL</p>

<form id="employeeForm">
    <input type="hidden" id="employeeId" />
    <input type="text" id="name" placeholder="Name" required />
    <input type="email" id="email" placeholder="Email" required />
    <input type="text" id="department" placeholder="Department" />
    <input type="number" step="0.01" id="salary" placeholder="Salary" />
    <div class="actions">
        <button type="submit" class="primary" id="submitBtn">Add Employee</button>
        <button type="button" class="secondary" id="cancelEditBtn" style="display:none;">Cancel</button>
    </div>
</form>

<div id="statusMsg"></div>

<table>
    <thead>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Email</th>
            <th>Department</th>
            <th>Salary</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody id="employeeTableBody">
        <!-- rows injected by JS -->
    </tbody>
</table>

<script>
    // Servlet is mapped to /employees, relative to this app's context path
    const API_URL = '<%= request.getContextPath() %>/employees';

    const form = document.getElementById('employeeForm');
    const idField = document.getElementById('employeeId');
    const nameField = document.getElementById('name');
    const emailField = document.getElementById('email');
    const departmentField = document.getElementById('department');
    const salaryField = document.getElementById('salary');
    const submitBtn = document.getElementById('submitBtn');
    const cancelEditBtn = document.getElementById('cancelEditBtn');
    const statusMsg = document.getElementById('statusMsg');
    const tableBody = document.getElementById('employeeTableBody');

    function showStatus(message, type) {
        statusMsg.textContent = message;
        statusMsg.className = type || '';
        if (message) {
            setTimeout(() => { statusMsg.textContent = ''; statusMsg.className = ''; }, 3000);
        }
    }

    function resetForm() {
        form.reset();
        idField.value = '';
        submitBtn.textContent = 'Add Employee';
        cancelEditBtn.style.display = 'none';
    }

    async function loadEmployees() {
        try {
            const res = await fetch(API_URL);
            if (!res.ok) throw new Error('Failed to load employees');
            const employees = await res.json();
            renderTable(employees);
        } catch (err) {
            showStatus(err.message, 'error');
        }
    }

    function renderTable(employees) {
        tableBody.innerHTML = '';
        employees.forEach(emp => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${emp.id}</td>
                <td>${escapeHtml(emp.name)}</td>
                <td>${escapeHtml(emp.email)}</td>
                <td>${escapeHtml(emp.department || '')}</td>
                <td>${emp.salary != null ? Number(emp.salary).toFixed(2) : ''}</td>
                <td class="actions-col">
                    <button class="edit" onclick='startEdit(${JSON.stringify(emp)})'>Edit</button>
                    <button class="danger" onclick="deleteEmployee(${emp.id})">Delete</button>
                </td>
            `;
            tableBody.appendChild(tr);
        });
    }

    function escapeHtml(str) {
        if (str == null) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    }

    function startEdit(emp) {
        idField.value = emp.id;
        nameField.value = emp.name;
        emailField.value = emp.email;
        departmentField.value = emp.department || '';
        salaryField.value = emp.salary != null ? emp.salary : '';
        submitBtn.textContent = 'Update Employee';
        cancelEditBtn.style.display = 'inline-block';
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    cancelEditBtn.addEventListener('click', resetForm);

    form.addEventListener('submit', async (e) => {
        e.preventDefault();

        const payload = {
            name: nameField.value.trim(),
            email: emailField.value.trim(),
            department: departmentField.value.trim(),
            salary: salaryField.value ? parseFloat(salaryField.value) : 0
        };

        const id = idField.value;
        const isEdit = !!id;
        const url = isEdit ? `${API_URL}?id=${id}` : API_URL;
        const method = isEdit ? 'PUT' : 'POST';

        try {
            const res = await fetch(url, {
                method: method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            if (!res.ok) {
                const errBody = await res.json().catch(() => ({}));
                throw new Error(errBody.error || 'Request failed');
            }
            showStatus(isEdit ? 'Employee updated' : 'Employee added', 'success');
            resetForm();
            loadEmployees();
        } catch (err) {
            showStatus(err.message, 'error');
        }
    });

    async function deleteEmployee(id) {
        if (!confirm('Delete this employee?')) return;
        try {
            const res = await fetch(`${API_URL}?id=${id}`, { method: 'DELETE' });
            if (!res.ok) {
                const errBody = await res.json().catch(() => ({}));
                throw new Error(errBody.error || 'Delete failed');
            }
            showStatus('Employee deleted', 'success');
            loadEmployees();
        } catch (err) {
            showStatus(err.message, 'error');
        }
    }

    // initial load
    loadEmployees();
</script>

</body>
</html>
