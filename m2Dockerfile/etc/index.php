<?php
$servername = getenv('MAGENTO_DATABASE_HOST');
$username = getenv('MAGENTO_USER');
$password = getenv('MAGENTO_DATABASE_PASSWORD');
$dbname = getenv('MAGENTO_DATABASE_NAME');

try {
  $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
  // set the PDO error mode to exception
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  echo "Connected successfully";
} catch(PDOException $e) {
  echo "Connection failed: " . $e->getMessage();
}
?>
