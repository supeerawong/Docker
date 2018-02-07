# Docker

Build image with code: \
sudo docker build -t supeerawong/alfresco 

Run container with code: \
sudo docker run --name 'mysql' -d -p 3306:3306 
    -e MYSQL_ROOT_PASSWORD=secret 
    -e MYSQL_DATABASE=alfresco 
    -e MYSQL_USER=alfresco 
    -e MYSQL_PASSWORD=secret
    -v /mnt/mysql:/var/lib/mysql
    mysql 
    --character-set-server=utf8 
    --collation-server=utf8_general_ci 
    --max_connections=1024
    
sudo docker run --name='alfresco' -d -p 8080:8080 
    -v /mnt/alfresco_content_store:/mnt/content_store 
    -e CONTENT_STORE=/mnt/content_store 
    -e DB_KIND=mysql 
    -e DB_HOST=mysql 
    -e DB_PASSWORD=secret 
    --link mysql:mysql 
    supeerawong/docker 

Connect to Localhost:8080/share 

user: admin pass: admin 

Enjoy!
