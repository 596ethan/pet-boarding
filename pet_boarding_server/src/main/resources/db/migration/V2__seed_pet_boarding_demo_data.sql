INSERT INTO app_user (id, username, password, display_name, token)
VALUES (1, 'admin', '123456', 'Front Desk Clerk', 'demo-token-admin');

INSERT INTO owner (id, name, phone, remark)
VALUES
  (1, 'Lin Yu', '13800010001', 'Prefers morning pickup confirmation.'),
  (2, 'Chen Xiao', '13800010002', 'Pet warms up slowly with strangers.'),
  (3, 'Zhou Ning', '13800010003', 'Review care records before checkout.');

INSERT INTO pet (id, owner_id, name, type, breed, age, weight, temperament)
VALUES
  (1, 1, 'Tuan Tuan', 'Cat', 'British Shorthair', 3, 4.80, 'Quiet and sensitive to noise.'),
  (2, 2, 'Cola', 'Dog', 'Corgi', 2, 11.20, 'Active and likes walks.'),
  (3, 3, 'Nuomi', 'Cat', 'Ragdoll', 4, 5.60, 'Friendly and needs daily brushing.');

INSERT INTO room (id, room_no, status)
VALUES
  (1, 'A101', 'OCCUPIED'),
  (2, 'A102', 'AVAILABLE'),
  (3, 'B201', 'AVAILABLE'),
  (4, 'B202', 'AVAILABLE');

INSERT INTO boarding_order (id, owner_id, pet_id, room_id, status, checkin_time, checkout_time, remark)
VALUES
  (1, 1, 1, 1, 'CHECKED_IN', CURRENT_TIMESTAMP, NULL, 'Three-day boarding; keep litter box clean.'),
  (2, 2, 2, NULL, 'PENDING', NULL, NULL, 'Afternoon check-in; prefer a quiet room.'),
  (3, 3, 3, 3, 'COMPLETED', TIMESTAMPADD(DAY, -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, 'Checkout completed with good owner feedback.');

INSERT INTO care_record (id, order_id, type, content, record_time)
VALUES
  (1, 1, 'FEEDING', 'Morning feeding completed. Water is normal.', CURRENT_TIMESTAMP),
  (2, 3, 'CLEANING', 'Room cleaned and coat brushed before checkout.', CURRENT_TIMESTAMP);
