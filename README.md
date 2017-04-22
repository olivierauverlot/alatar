# Alatar

Alatar is an experimental project to analyze dependencies between the entities of a PostgreSQL schema.

The project don't use PostgreSQL parser to extract informations from the database schema. You must only give to him a structure only dump file. The table below lists the SQL objects that are managed by Alatar. A star icon indicates that the object is already supported.

SQL Object | Status
---------- | ------
Extension | :star:
Schema | public schema only
Table | :star:
Inherited table | :star:
Foreign table |
View | :star:
Column | :star:
Data type | :star:
Enumeration |
Composite type |
Unique constraint | :star:
Primary Key constraint | :star:
Foreign Key constraint | :star:
Not Null constraint | :star:
Default constraint |
Inherited constraint | :star:
Check constraint | :star:
PL/pgSQL function | :star:
Comment | :star:
Rule | :star:
Sequence | :star:
Trigger | :star:
SQL request |

Alatar builds a model from the database schema. You can study it with the request API. If you are not a Perl programmer, you can also save the model with a XML exporter and use your tools to extract what you want.