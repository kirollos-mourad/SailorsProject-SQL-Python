import tkinter as tk
from tkinter import ttk, messagebox
import pyodbc

# ==========================================
# SAILORS PROJECT - SQL SERVER + PYTHON
# ==========================================

CONNECTION = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=.\\SQLEXPRESS;"
    "DATABASE=SailorsProject;"
    "Trusted_Connection=yes;"
)

QUESTIONS = [
    (
        "Question 1",
        "Sailors who reserved red boats",
        """
        SELECT DISTINCT S.sname, S.age
        FROM dbo.Sailors AS S
        JOIN dbo.Reserves AS R ON S.sid = R.sid
        JOIN dbo.Boats AS B ON R.bid = B.bid
        WHERE B.color = 'red'
        ORDER BY S.age ASC
        """
    ),
    (
        "Question 2",
        "Sailors who reserved two different boats on the same day",
        """
        SELECT DISTINCT S.sid, S.sname
        FROM dbo.Sailors AS S
        JOIN dbo.Reserves AS R1 ON S.sid = R1.sid
        JOIN dbo.Reserves AS R2
          ON R1.sid = R2.sid
         AND R1.day = R2.day
         AND R1.bid <> R2.bid
        ORDER BY S.sid
        """
    ),
    (
        "Question 3",
        "Sailor(s) who reserved the most boats",
        """
        SELECT TOP 1 WITH TIES
            S.sid,
            S.sname,
            COUNT(DISTINCT R.bid) AS total_boats
        FROM dbo.Sailors AS S
        JOIN dbo.Reserves AS R ON S.sid = R.sid
        GROUP BY S.sid, S.sname
        ORDER BY COUNT(DISTINCT R.bid) DESC
        """
    ),
    (
        "Question 4",
        "Sailors who reserved both red and green boats",
        """
        SELECT S.sid, S.sname
        FROM dbo.Sailors AS S
        JOIN dbo.Reserves AS R ON S.sid = R.sid
        JOIN dbo.Boats AS B ON R.bid = B.bid
        WHERE B.color IN ('red', 'green')
        GROUP BY S.sid, S.sname
        HAVING COUNT(DISTINCT B.color) = 2
        ORDER BY S.sid
        """
    ),
    (
        "Question 5",
        "Sailors who reserved every boat",
        """
        SELECT S.sid, S.sname
        FROM dbo.Sailors AS S
        JOIN dbo.Reserves AS R ON S.sid = R.sid
        GROUP BY S.sid, S.sname
        HAVING COUNT(DISTINCT R.bid) = (
            SELECT COUNT(*) FROM dbo.Boats
        )
        ORDER BY S.sid
        """
    )
]


def show_results(tree, columns, rows):
    tree.delete(*tree.get_children())
    tree["columns"] = columns
    tree["show"] = "headings"

    for column in columns:
        tree.heading(column, text=column)
        tree.column(column, width=160, anchor="center")

    for row in rows:
        tree.insert("", "end", values=row)


def main():
    root = tk.Tk()
    root.title("Sailors Project - SQL & Python")
    root.geometry("900x550")
    root.minsize(700, 420)

    style = ttk.Style()
    style.configure("Treeview", rowheight=30, font=("Arial", 10))
    style.configure("Treeview.Heading", font=("Arial", 10, "bold"))
    style.configure("TNotebook.Tab", padding=[15, 8])

    title = ttk.Label(
        root,
        text="SAILORS PROJECT",
        font=("Arial", 22, "bold")
    )
    title.pack(pady=(18, 5))

    subtitle = ttk.Label(
        root,
        text="Database Queries and Results | SQL Server + Python",
        font=("Arial", 11)
    )
    subtitle.pack(pady=(0, 12))

    notebook = ttk.Notebook(root)
    notebook.pack(fill="both", expand=True, padx=18, pady=10)

    try:
        with pyodbc.connect(CONNECTION, timeout=5) as conn:
            cursor = conn.cursor()

            for tab_name, question, sql in QUESTIONS:
                frame = ttk.Frame(notebook, padding=15)
                notebook.add(frame, text=tab_name)

                question_label = ttk.Label(
                    frame,
                    text=question,
                    font=("Arial", 12, "bold"),
                    wraplength=780
                )
                question_label.pack(anchor="w", pady=(0, 15))

                table_frame = ttk.Frame(frame)
                table_frame.pack(fill="both", expand=True)

                tree = ttk.Treeview(
                    table_frame,
                    height=12
                )
                tree.pack(
                    side="left",
                    fill="both",
                    expand=True
                )

                scrollbar = ttk.Scrollbar(
                    table_frame,
                    orient="vertical",
                    command=tree.yview
                )
                scrollbar.pack(side="right", fill="y")
                tree.configure(yscrollcommand=scrollbar.set)

                cursor.execute(sql)
                rows = cursor.fetchall()
                columns = [item[0] for item in cursor.description]

                show_results(tree, columns, rows)

                result_label = ttk.Label(
                    frame,
                    text=f"Number of results: {len(rows)}"
                )
                result_label.pack(anchor="w", pady=(12, 0))

    except Exception as error:
        messagebox.showerror(
            "Project Error",
            f"Could not load project results:\n\n{error}"
        )
        root.destroy()
        return

    footer = ttk.Label(
        root,
        text="Database: SailorsProject",
        font=("Arial", 9)
    )
    footer.pack(pady=(0, 12))

    root.mainloop()



main()
