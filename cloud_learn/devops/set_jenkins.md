# 前置准备工作

##  中间件部署

####  1、部署Sentinel

a、创建优状态服务

![image-20220327210219208](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210219208.png)

b、指定容器镜像

![image-20220327210329816](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210329816.png)

C、默认下一步创建

#### 2、MongoDB创建

![image-20220327210617044](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210617044.png)

##### 选择应用模板进行创建

| <img src="https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210632126.png" alt="image-20220327210632126" style="zoom:80%;" /><img src="https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210704351.png" alt="image-20220327210632126" style="zoom:80%;" /> |      |
| ------------------------------------------------------------ | ---- |
|                                                              |      |
###### 配置账户密码   
| <img src="https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327211232257.png" alt="image-20220327211232257" style="zoom: 67%;" /><img src="https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327211411571.png" alt="image-20220327211232257" style="zoom: 75%;" /> |      |
| ------------------------------------------------------------ | ---- |
|                                                              |      |

###### 密钥配置



![image-20220327205155161](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327205155161.png)

###### 配置案例云镜像仓库信息

1、创建名称

![image-20220327205235357](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327205235357.png)

2、配置案例云仓库地址（或其他仓库）

![image-20220327205505037](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327205505037.png)



## 网络环境优化

#### 配置maven

>- 使用admin登陆ks
>- 进入集群管理
>- 进入配置中心
>- 找到配置
>
>- - ks-devops-agent
>  - 修改这个配置。加入maven阿里云镜像加速地址

![image-20220327221348297](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327221348297.png)

![image-20220327221552455](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327221552455.png)

```xml
<mirror>
    <id>nexus-aliyun</id>
    <mirrorOf>*,!jeecg,!jeecg-snapshots</mirrorOf>
    <name>Nexus aliyun</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public</url>
</mirror> 

```

![image-20220322213322073](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220322213322073.png)

# 创建devops工程

## 1、创建devops

> 进入分公司，找到devops工程，点击创建

![image-20220327213430426](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327213430426.png)

![image-20220327213533498](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327213533498.png)

## 2、创建凭证

### 1、创建git凭证

![image-20220327220021610](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220021610.png)

### 2、创建案例镜像登录凭证

![image-20220327220200098](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220200098.png)

## 3、进入工程创建流水线

![image-20220327214137747](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214137747.png)

### 方式1：手动配置Jenkins

#### 1、配置流水线名称

![image-20220327214301720](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214301720.png)

#### 2、编辑流水线

> 选择持续集成模板

![image-20220327214443889](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214443889.png)

![image-20220327214629468](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214629468.png)

##### 1、拉取代码

![image-20220327214859690](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214859690.png)

###### a) 指定容器

![image-20220327215151603](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327215151603.png)

b) 添加嵌套步骤

添加git 拉取代码

| ![image-20220327215352956](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327215352956.png)![image-20220327215529925](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327215529925.png) |      |
| ------------------------------------------------------------ | ---- |
|                                                              |      |

> 完整jenkins
>
> ```sh
> stages {
>     stage('拉取代码') {
>       agent none
>       steps {
>         container('maven') {
>           git(url: 'https://gitee.com/leifengyang/yygh-parent.git', credentialsId: 'gitee-id', branch: 'master', changelog: true, poll: false)
>           sh 'ls -al'
>         }
> 
>       }
>     }
> ```
>
> 

##### 2、项目编译

###### a) 指定容器

###### b)添加嵌套步骤

1、确定文件是否存在，添加shell

![image-20220327220544541](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220544541.png)

2、编译代码，添加shell

```sh
mvn clean package -Dmaven.test.skip=true
```

![image-20220327220639181](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220639181.png)

3、确定是否编译成功,添加shell

```sh
ls hospital-manage/target
```

![image-20220327220812507](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220812507.png)

> 完整jenkins
>
> ```sh
>  stage('项目编译') {
>       agent none
>       steps {
>         container('maven') {
>           sh 'ls'
>           sh 'mvn clean package -Dmaven.test.skip=true'
>           sh 'ls hospital-manage/target'
>         }
> 
>       }
>     }
> ```
>
> 

##### 3、构建镜像

###### a) 指定容器

###### b)添加嵌套步骤

​	1、确定文件是否存在

​    2、构建镜像

```sh
docker build -t hospital-manage:latest -f hospital-manage/Dockerfile  ./hospital-manage/
```

![image-20220404142832911](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220404142832911.png)

> 完整jenkins
>
> ```sh
> stage('default-2') {
>       parallel {
>         stage('构建hospital-manage镜像') {
>           agent none
>           steps {
>             container('maven') {
>               sh 'ls hospital-manage/target'
>               sh 'docker build -t hospital-manage:latest -f hospital-manage/Dockerfile  ./hospital-manage/'
>             }
> 
>           }
>         }
> 
>        
> 
>         
>     }
> ```
>
> 

##### 4、推送镜像到仓库

###### a、指定容器

###### b、添加凭证

|                                                              |      |
| ------------------------------------------------------------ | ---- |
| ![image-20220404143411938](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220404143411938.png)![image-20220404143347876](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220404143347876.png) |      |



###### c、登录私有容器库

```sh
echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin
```

###### d、修改镜像tag

```sh
docker tag hospital-manage:latest $REGISTRY/$DOCKERHUB_NAMESPACE/hospital-manage:SNAPSHOT-$BUILD_NUMBER
```

###### e、推送镜像

```sh
docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/hospital-manage:SNAPSHOT-$BUILD_NUMBER>
```

> 完整jenkins
>
> ```sh
>  stage('default-3') {
>       parallel {
>         stage('推送hospital-manage镜像') {
>           agent none
>           steps {
>             container('maven') {
>               withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
>                 sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
>                 sh 'docker tag hospital-manage:latest $REGISTRY/$DOCKERHUB_NAMESPACE/hospital-manage:SNAPSHOT-$BUILD_NUMBER'
>                 sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/hospital-manage:SNAPSHOT-$BUILD_NUMBER'
>               }
> 
>             }
> 
>           }
>         }
>       }
>   }
> ```

##### 5、部署到dev环境

1、添加任务

|                                                              |                                                              |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![image-20220404145159835](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220404145159835.png) | ![image-20220404145312210](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220404145312210.png) |

> 1、指定凭证
>
> 2、指定配置文件路径
>
> > 完整jenkins
> >
> > ```sh
> > stage('default-4') {
> >       parallel {
> >         stage('hospital-manage - 部署到dev环境') {
> >           agent none
> >           steps {
> >             kubernetesDeploy(configs: 'hospital-manage/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
> >           }
> >         }
> >   }
> > ```

### 流水线jenkins

```sh
pipeline {
  agent {
    node {
      label 'maven'
    }

  }
  stages {
    stage('拉取代码') {
      agent none
      steps {
        container('maven') {
          git(url: 'https://gitee.com/leifengyang/yygh-parent.git', credentialsId: 'gitee-id', branch: 'master', changelog: true, poll: false)
          sh 'ls -al'
        }

      }
    }

    stage('项目编译') {
      agent none
      steps {
        container('maven') {
          sh 'ls'
          sh 'mvn clean package -Dmaven.test.skip=true'
          sh 'ls hospital-manage/target'
        }

      }
    }

    stage('default-2') {
      parallel {
        stage('构建hospital-manage镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls hospital-manage/target'
              sh 'docker build -t hospital-manage:latest -f hospital-manage/Dockerfile  ./hospital-manage/'
            }

          }
        }

        stage('构建server-gateway镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls server-gateway/target'
              sh 'docker build -t server-gateway:latest -f server-gateway/Dockerfile  ./server-gateway/'
            }

          }
        }

        stage('构建service-cmn镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls service/service-cmn/target'
              sh 'docker build -t service-cmn:latest -f service/service-cmn/Dockerfile  ./service/service-cmn/'
            }

          }
        }

        stage('构建service-hosp镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls service/service-hosp/target'
              sh 'docker build -t service-hosp:latest -f service/service-hosp/Dockerfile  ./service/service-hosp/'
            }

          }
        }

        stage('构建service-order镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls service/service-order/target'
              sh 'docker build -t service-order:latest -f service/service-order/Dockerfile  ./service/service-order/'
            }

          }
        }

        stage('构建service-oss镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls service/service-oss/target'
              sh 'docker build -t service-oss:latest -f service/service-oss/Dockerfile  ./service/service-oss/'
            }

          }
        }

        stage('构建service-sms镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls service/service-sms/target'
              sh 'docker build -t service-sms:latest -f service/service-sms/Dockerfile  ./service/service-sms/'
            }

          }
        }

        stage('构建service-statistics镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls service/service-statistics/target'
              sh 'docker build -t service-statistics:latest -f service/service-statistics/Dockerfile  ./service/service-statistics/'
            }

          }
        }

        stage('构建service-task镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls service/service-task/target'
              sh 'docker build -t service-task:latest -f service/service-task/Dockerfile  ./service/service-task/'
            }

          }
        }

        stage('构建service-user镜像') {
          agent none
          steps {
            container('maven') {
              sh 'ls service/service-user/target'
              sh 'docker build -t service-user:latest -f service/service-user/Dockerfile  ./service/service-user/'
            }

          }
        }

      }
    }

    stage('default-3') {
      parallel {
        stage('推送hospital-manage镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag hospital-manage:latest $REGISTRY/$DOCKERHUB_NAMESPACE/hospital-manage:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/hospital-manage:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

        stage('推送server-gateway镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag server-gateway:latest $REGISTRY/$DOCKERHUB_NAMESPACE/server-gateway:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/server-gateway:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

        stage('推送service-cmn镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag service-cmn:latest $REGISTRY/$DOCKERHUB_NAMESPACE/service-cmn:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/service-cmn:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

        stage('推送service-hosp镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag service-hosp:latest $REGISTRY/$DOCKERHUB_NAMESPACE/service-hosp:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/service-hosp:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

        stage('推送service-order镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag service-order:latest $REGISTRY/$DOCKERHUB_NAMESPACE/service-order:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/service-order:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

        stage('推送service-oss镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag service-oss:latest $REGISTRY/$DOCKERHUB_NAMESPACE/service-oss:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/service-oss:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

        stage('推送service-sms镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag service-sms:latest $REGISTRY/$DOCKERHUB_NAMESPACE/service-sms:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/service-sms:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

        stage('推送service-statistics镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag service-statistics:latest $REGISTRY/$DOCKERHUB_NAMESPACE/service-statistics:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/service-statistics:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

        stage('推送service-task镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag service-task:latest $REGISTRY/$DOCKERHUB_NAMESPACE/service-task:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/service-task:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

        stage('推送service-user镜像') {
          agent none
          steps {
            container('maven') {
              withCredentials([usernamePassword(credentialsId : 'aliyun-docker-registry' ,usernameVariable : 'DOCKER_USER_VAR' ,passwordVariable : 'DOCKER_PWD_VAR' ,)]) {
                sh 'echo "$DOCKER_PWD_VAR" | docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                sh 'docker tag service-user:latest $REGISTRY/$DOCKERHUB_NAMESPACE/service-user:SNAPSHOT-$BUILD_NUMBER'
                sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/service-user:SNAPSHOT-$BUILD_NUMBER'
              }

            }

          }
        }

      }
    }

    stage('default-4') {
      parallel {
        stage('hospital-manage - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'hospital-manage/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

        stage('server-gateway - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'server-gateway/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

        stage('service-cmn - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'service/service-cmn/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

        stage('service-hosp - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'service/service-hosp/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

        stage('service-order - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'service/service-order/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

        stage('service-oss - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'service/service-oss/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

        stage('service-sms - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'service/service-sms/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

        stage('service-statistics - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'service/service-statistics/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

        stage('service-task - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'service/service-task/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

        stage('service-user - 部署到dev环境') {
          agent none
          steps {
            kubernetesDeploy(configs: 'service/service-user/deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
          }
        }

      }
    }

    stage('发送确认邮件') {
      agent none
      steps {
        mail(to: '849109312@qq.com', subject: '构建结果', body: '"构建成功了  $BUILD_NUMBER"')
      }
    }

  }
  environment {
    DOCKER_CREDENTIAL_ID = 'dockerhub-id'
    GITHUB_CREDENTIAL_ID = 'github-id'
    KUBECONFIG_CREDENTIAL_ID = 'demo-kubeconfig'
    REGISTRY = 'registry.cn-hangzhou.aliyuncs.com'
    DOCKERHUB_NAMESPACE = 'wjh_ruoyi'
    GITHUB_ACCOUNT = 'kubesphere'
    APP_NAME = 'devops-java-sample'
    ALIYUNHUB_NAMESPACE = 'wjh_ruoyi'
  }
  parameters {
    string(name: 'TAG_NAME', defaultValue: '', description: '')
  }
}
```

### 方式二：读取项目自带jenkins

1、指定git路径

![image-20220404150002393](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220404150002393.png)

![image-20220404150031463](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220404150031463.png)

![image-20220404145920719](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220404145920719.png)