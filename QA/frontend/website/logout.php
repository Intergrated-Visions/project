<?php
// Expire the session cookie by setting its expiration time to a past value
setcookie("session", '', time() - 3600);

// Redirect to the login page or any other desired page
header("Location: login.php");
exit;
?>