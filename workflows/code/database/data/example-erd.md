-- Generated from example-schema.csv on YYYY-MM-DD. Do not edit manually.
-- Regenerate by running /query or /optimize and selecting the corresponding CSV.

// Example DBML — shows the generated format for reference.
// Real ERD files are auto-generated from *-schema.csv by the workflow.

Table users {
  id integer [pk]
  email varchar [not null]
  created_at timestamp
}

Table orders {
  id integer [pk]
  user_id integer [ref: > users.id]
  total decimal
  created_at timestamp
}
