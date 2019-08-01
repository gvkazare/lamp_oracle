<?php
$db = new PDO('mysql:host=localhost', 'root', null);
?>
<!doctype html>
<html lang=en>
<head>
    <meta charset=utf-8>
    <title>Hello World from LAMP ORACLE</title>

    <style>
        @import 'https://fonts.googleapis.com/css?family=Montserrat|Raleway|Source+Code+Pro';
        body { font-family: 'Raleway', sans-serif; }
        h2 { font-family: 'Montserrat', sans-serif; }
        pre {
            font-family: 'Source Code Pro', monospace;
            padding: 16px;
            overflow: auto;
            font-size: 85%;
            line-height: 1.45;
            background-color: #f7f7f7;
            border-radius: 3px;
            word-wrap: normal;
        }
        .container {
            max-width: 1024px;
            width: 100%;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h2>Welcome to:</h2>
            <h1>gvkazare/lamp_oracle</h1>
        </header>
        <article>
            <p>
                For documentation, <a href="https://github.com/gvkazare/lamp_oracle" target="_blank">click here</a>.
            </p>
        </article>
        <section>
            <pre>
OS: <?php echo php_uname('s'); ?><br/>
Apache: <?php echo apache_get_version(); ?><br/>
MySQL Version: <?php echo $db->getAttribute( PDO::ATTR_SERVER_VERSION ); ?><br/>
PHP Version: <?php echo phpversion(); ?><br/>
phpMyAdmin Version: <?php echo getenv('PHPMYADMIN_VERSION'); ?><br/>
            </pre>
        </section>
    </div>

</body>
</html>
