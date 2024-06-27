CREATE INDEX student_enrollment ON enrollments (student_id);

CREATE INDEX course_enrollment ON enrollments (course_id);

CREATE INDEX course_id ON courses (id);

CREATE INDEX course_dept ON courses (department);

CREATE INDEX course_no ON courses (number);

CREATE INDEX course_sem ON courses (semester);

CREATE INDEX course_satisfies ON satisfies (course_id);