package com.example.servlet;

import com.example.model.Employee;
import com.example.util.HibernateUtil;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

@WebServlet("/employees")
public class EmployeeServlet extends HttpServlet {

    private final Gson gson = new Gson();
    private SessionFactory sessionFactory;

    @Override
    public void init() throws ServletException {
        sessionFactory = HibernateUtil.getSessionFactory();
    }

    // ---------- CREATE ----------
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        Employee employee = readBody(req, Employee.class);

        Transaction tx = null;
        try (Session session = sessionFactory.openSession()) {
            tx = session.beginTransaction();
            session.save(employee); // populates employee.id via IDENTITY strategy
            tx.commit();

            resp.setStatus(HttpServletResponse.SC_CREATED);
            writeJson(resp, employee);

        } catch (HibernateException e) {
            if (tx != null) tx.rollback();
            sendError(resp, "Failed to create employee: " + e.getMessage());
        }
    }

    // ---------- READ (single by id, or all) ----------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        String idParam = req.getParameter("id");

        try (Session session = sessionFactory.openSession()) {

            if (idParam != null) {
                Employee employee = session.get(Employee.class, Integer.parseInt(idParam));
                if (employee != null) {
                    writeJson(resp, employee);
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    writeJson(resp, "{\"error\":\"Employee not found\"}");
                }
            } else {
                Query<Employee> query = session.createQuery("FROM Employee ORDER BY id", Employee.class);
                List<Employee> employees = query.list();
                writeJson(resp, employees);
            }

        } catch (HibernateException e) {
            sendError(resp, "Failed to fetch employee(s): " + e.getMessage());
        }
    }

    // ---------- UPDATE ----------
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        String idParam = req.getParameter("id");

        if (idParam == null) {
            sendError(resp, "Missing required parameter: id");
            return;
        }

        Employee incoming = readBody(req, Employee.class);
        int id = Integer.parseInt(idParam);

        Transaction tx = null;
        try (Session session = sessionFactory.openSession()) {
            tx = session.beginTransaction();

            Employee existing = session.get(Employee.class, id);
            if (existing == null) {
                tx.rollback();
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                writeJson(resp, "{\"error\":\"Employee not found\"}");
                return;
            }

            existing.setName(incoming.getName());
            existing.setEmail(incoming.getEmail());
            existing.setDepartment(incoming.getDepartment());
            existing.setSalary(incoming.getSalary());

            session.update(existing);
            tx.commit();

            writeJson(resp, existing);

        } catch (HibernateException e) {
            if (tx != null) tx.rollback();
            sendError(resp, "Failed to update employee: " + e.getMessage());
        }
    }

    // ---------- DELETE ----------
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        String idParam = req.getParameter("id");

        if (idParam == null) {
            sendError(resp, "Missing required parameter: id");
            return;
        }

        int id = Integer.parseInt(idParam);

        Transaction tx = null;
        try (Session session = sessionFactory.openSession()) {
            tx = session.beginTransaction();

            Employee existing = session.get(Employee.class, id);
            if (existing == null) {
                tx.rollback();
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                writeJson(resp, "{\"error\":\"Employee not found\"}");
                return;
            }

            session.delete(existing);
            tx.commit();

            writeJson(resp, "{\"message\":\"Employee deleted successfully\"}");

        } catch (HibernateException e) {
            if (tx != null) tx.rollback();
            sendError(resp, "Failed to delete employee: " + e.getMessage());
        }
    }

    // ---------- helpers ----------

    private <T> T readBody(HttpServletRequest req, Class<T> clazz) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return gson.fromJson(sb.toString(), clazz);
    }

    private void writeJson(HttpServletResponse resp, Object payload) throws IOException {
        try (PrintWriter out = resp.getWriter()) {
            if (payload instanceof String) {
                out.print(payload); // already-formed JSON string
            } else {
                out.print(gson.toJson(payload));
            }
        }
    }

    private void sendError(HttpServletResponse resp, String message) throws IOException {
        resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        writeJson(resp, "{\"error\":\"" + message.replace("\"", "'") + "\"}");
    }
}