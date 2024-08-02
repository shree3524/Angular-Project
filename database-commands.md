### connect the database instance
root@Database

   ```
   apt update
```
install mariadb server
```
apt install mariadb-server -y
systemctl start mariadb
systemctl enable mariadb
```
install git 
```
 apt install git -y
 git clone https://github.com/abhipraydhoble/Project-Angular-App.git
```
go to directory
 ```
   cd Project-Angular-App/
```
login to database
 ```
 sudo mysql -h database-1.cxqukacgq5pj.us-east-1.rds.amazonaws.com -u Angular-db -pPasswd12345678
```
```
 CREATE DATABASE springbackend;
  ```
```
 exit
```
connect the backend instance run the backend commands
