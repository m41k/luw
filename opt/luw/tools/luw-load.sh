function load(){

cat <<EOF1

        <head>
        <title>Teste</title>
                <script type="text/javascript">
                function id(el) {
                        return document.getElementById(el);
                }
                function hide(el) {
                        id(el).style.display = 'none';//escondendo tudo
                }
                window.onload = function() {
                        id('all').style.display = 'block';//liberando qndo terminar
                        hide('loading');
                }
                </script>
        </head>
        <body>
        <section id="all" class="content">
EOF1
        echo "<table border='0' width='100%' height='90%'>"
        echo "<tr>"
        echo "<td>"
        #echo "<iframe src=luw-images.sh width='100%' height='100%'></iframe>"
        #echo "<embed src=luw-images.sh width='100%' height='100%'></embed>"
        echo "<object data=$1 width='100%' height='100%'></object>"
        echo "</td>"
        echo "</tr>"
        echo "</table>"

cat <<EOF2

        </section><!-- #all -->

        <center><img src="https://raw.githubusercontent.com/m41k/luw/master/var/www/html/img/box.gif" alt="" id="loading" class="content"/><center>

        <script type="text/javascript">
                hide('all');
        </script>
        </body>
        </html>

EOF2

}
