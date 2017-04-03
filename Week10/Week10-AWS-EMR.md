## Build Own Hadoop/Spark Cluster Using Amazon EMR

This tutorial is based on http://spark.rstudio.com/examples-emr.html

### Launch a cluster in EMR

- Create a Cluster
- Choose older Spark version (1.6)
- Make sure to create a EC2 key pair if you do not have yet
- Set security groups to make sure port 22 and 8787 open to you at least (I simply to make it open to all for simiplicity but not recommended)

Finally hit create cluster and wait a few minutes

### Install Rstudio Server

Once Master node is ready, ssh to the server to install Rstudio server

```
ssh -i ~/spark.pem hadoop@ec2-54-234-8-132.compute-1.amazonaws.com

sudo yum update
sudo yum install libcurl-devel openssl-devel libxml2-devel

wget https://download2.rstudio.org/rstudio-server-rhel-1.0.136-x86_64.rpm
sudo yum install --nogpgcheck rstudio-server-rhel-1.0.136-x86_64.rpm

# Make User
sudo useradd -m rstudio-user
sudo passwd rstudio-user # password biostat597e

# Create new directory in hdfs
hadoop fs -mkdir /user/rstudio-user
hadoop fs -chmod 777 /user/rstudio-user

```

The yum install may be locked, so we may install dplyr package as it takes a while

```
sudo R
install.packages("dplyr")
```

Now we can login Rstudio server in web browser

```
ec2-54-234-8-132.compute-1.amazonaws.com:8787
```

Within Rstudio, we can install packages for sparklyr and etc


### Download data set for testing

Go back to Masater node in Terminal

```
# switch user
su rstudio-user

# Make download directory
mkdir /tmp/flights

# Download flight data by year
for i in {2005..2008}
  do
    echo "$(date) $i Download"
    fnam=$i.csv.bz2
    wget -O /tmp/flights/$fnam http://stat-computing.org/dataexpo/2009/$fnam
    echo "$(date) $i Unzip"
    bunzip2 /tmp/flights/$fnam
  done

# Download airline carrier data
wget -O /tmp/airlines.csv http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS

# Download airports data
wget -O /tmp/airports.csv https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat

```

Next upload those data to HDFS

```
hadoop fs -put /tmp/airlines.csv /user/rstudio-user
hadoop fs -put /tmp/airports.csv /user/rstudio-user
hadoop fs -put /tmp/flights /user/rstudio-user
```

### Connect to spark

First we create a yaml file for Spark configuration called config.yml

```
default:
  sparklyr.shell.executor-memory: 8G
  sparklyr.shell.driver-memory: 8G
  sparklyr.shell.num-executors: 2
  sparklyr.shell.executor-cores: 3
  spark.executor.memory: 8G
  spark.yarn.am.memory: 8G
  spark.executor.instances: 3
```

Then we connect to spark

```
library(sparklyr)
library(dplyr)

Sys.setenv(SPARK_HOME="/usr/lib/spark")

sc <- spark_connect("yarn-client", config = spark_config(), version = '1.6.3')
```

### Data Analysis
```
airports_tbl <- spark_read_csv(sc, "airports", "/user/rstudio-user/airports.csv")

airlines_tbl <- spark_read_csv(sc, "airlines", "/user/rstudio-user/airlines.csv")

flights_tbl <- spark_read_csv(sc, "flights", "/user/rstudio-user/flights/2005.csv")

model_data <- flights_tbl %>%
  filter(!is.na(arrdelay) & !is.na(depdelay) & !is.na(distance)) %>%
  filter(depdelay > 15 & depdelay < 240) %>%
  filter(arrdelay > -60 & arrdelay < 360) %>%
  filter(year >= 2003 & year <= 2007) %>%
  left_join(airlines_tbl, by = c("uniquecarrier" = "code")) %>%
  mutate(gain = depdelay - arrdelay) %>%
  select(year = Year, month = Month, arrdelay = ArrDelay,
         depdelay = DepDelay, distance = Distance,
         uniquecarrier = UniqueCarrier, description = Description, gain)

# Summarize data by carrier
model_data %>%
  group_by(uniquecarrier) %>%
  summarize(description = min(description), gain=mean(gain),
            distance=mean(distance), depdelay=mean(depdelay)) %>%
  select(description, gain, distance, depdelay) %>%
  arrange(gain)

model_partition <- model_data %>%
  sdf_partition(train = 0.8, valid = 0.2, seed = 5555)

# Fit a linear model
ml1 <- model_partition$train %>%
  ml_linear_regression(gain ~ distance + depdelay + uniquecarrier)

# Summarize the linear model
summary(ml1)
```

## Remember to Terminate Your Cluster!!!
