
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
<link rel="stylesheet" type="text/css" href="style.css">
<title>Selected User</title>
</head>
<body>
<?php
include("/var/www/html/base.php");

$db_name = 'brvv';
$db_username =  'admin';
$db_pass =      '*11111aa';
$dbh = new PDO($dsn, $db_username, $db_pass);


$sql_select = "SELECT * FROM users";
$result = $dbh->query($sql_select);
$row = $result->fetch();
do
{
        printf("<p>User: " .$row['fst_name'] . " " .$row['lst_name'] ."</p>
        <p><i>Contacts</i></p><p>phone: " .$row['phone'] . "</p>---------<br/>"
        );
}
while($row = $result->fetch());
         ?>

</body>
</html>
