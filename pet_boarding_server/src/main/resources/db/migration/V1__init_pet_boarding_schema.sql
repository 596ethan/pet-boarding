CREATE TABLE app_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL UNIQUE,
  password VARCHAR(128) NOT NULL,
  display_name VARCHAR(64) NOT NULL,
  token VARCHAR(128) NOT NULL UNIQUE
);

CREATE TABLE owner (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  phone VARCHAR(32) NOT NULL,
  remark VARCHAR(255) NOT NULL DEFAULT ''
);

CREATE TABLE pet (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  owner_id BIGINT NOT NULL,
  name VARCHAR(64) NOT NULL,
  type VARCHAR(32) NOT NULL,
  breed VARCHAR(64) NOT NULL,
  age INT NOT NULL,
  weight DECIMAL(8, 2) NOT NULL,
  temperament VARCHAR(255) NOT NULL DEFAULT '',
  CONSTRAINT fk_pet_owner FOREIGN KEY (owner_id) REFERENCES owner(id)
);

CREATE TABLE room (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  room_no VARCHAR(32) NOT NULL UNIQUE,
  status VARCHAR(32) NOT NULL
);

CREATE TABLE boarding_order (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  owner_id BIGINT NOT NULL,
  pet_id BIGINT NOT NULL,
  room_id BIGINT NULL,
  status VARCHAR(32) NOT NULL,
  checkin_time TIMESTAMP NULL,
  checkout_time TIMESTAMP NULL,
  remark VARCHAR(255) NOT NULL DEFAULT '',
  CONSTRAINT fk_order_owner FOREIGN KEY (owner_id) REFERENCES owner(id),
  CONSTRAINT fk_order_pet FOREIGN KEY (pet_id) REFERENCES pet(id),
  CONSTRAINT fk_order_room FOREIGN KEY (room_id) REFERENCES room(id)
);

CREATE TABLE care_record (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id BIGINT NOT NULL,
  type VARCHAR(32) NOT NULL,
  content VARCHAR(500) NOT NULL,
  record_time TIMESTAMP NOT NULL,
  CONSTRAINT fk_care_order FOREIGN KEY (order_id) REFERENCES boarding_order(id)
);

CREATE INDEX idx_pet_owner_id ON pet(owner_id);
CREATE INDEX idx_order_owner_id ON boarding_order(owner_id);
CREATE INDEX idx_order_pet_id ON boarding_order(pet_id);
CREATE INDEX idx_order_room_id ON boarding_order(room_id);
CREATE INDEX idx_order_status ON boarding_order(status);
CREATE INDEX idx_care_order_id ON care_record(order_id);
