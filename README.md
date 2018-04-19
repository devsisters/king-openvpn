# King-OpenVPN (VPC peering)

AWS에서 VPC peering을 이용하여 원하는 모든 VPC에 접속 가능한 하나의 VPN을 만드는 테라폼 코드입니다.

**king** 디렉토리에는 **도쿄(ap-northeast-1, 고정)** region에 OpenVPN 인스턴스를 띄우는 코드가 들어있고, **target** 디렉토리에는 이 VPN을 통해 다른 VPC에 접속할 수 있도록 구성한 예제가 들어있습니다. 

**서울(ap-northeast-2)** region은 다른 region과의 vpc peering을 지원하지 않으므로, 서울을 포함한 여러 region들에 걸쳐서 VPN을 구성하는 경우에는 **strongswan** branch를 사용해주시기 바랍니다.

이 프로젝트는 **MacOS** 환경을 기준으로 작성되었습니다.


## 사전 작업
0. 모든 작업은 도쿄(ap-northeast-1) region에서 이루어집니다.
1. EC2 instance를 띄우는 데 쓸 key pair를 하나 생성합니다.
2. Terraform state를 저장하기 위한 S3 bucket을 하나 마련해둡니다.
3. EC2, VPC 및 S3에 접근 가능한 AWS access key를 마련하여 ~/.aws/credentials 에 저장합니다.
4. brew install terraform

## OpenVPN 띄우기
1. 먼저 king 디렉토리에 가서 `terraform.tfvars`를 생성하고 알맞게 수정합니다.
    ```
    $ cd king
    $ cp terraform.tfvars.example terraform.tfvars
    ```
    ```
    # king/terraform.tfvars
    
    public_key_name = "<< 사전 작업으로 만든 key pair 이름 >>"

    openvpn_admin_password = "<< OpenVPN 관리자 계정에 사용할 패스워드 >>"
    
    cidr_block = "<< VPN을 띄울 VPC의 CIDR block (기본값: 172.29.0.0/16) >>"
    ```
    
2. `common.tf`의 s3 bucket을 사전 작업으로 만든 bucket 이름으로 채워넣습니다.
    terraform.tfstate에는 현 terraform context가 관리하고 있는 모든 aws resource 정보가 저장됩니다.
    local에 저장할 수도 있지만 remote에 저장하여 다른 terraform context(이 VPN과 연결될 resource들)에서 가져다 쓸 수 있도록 합니다.
    ```
    # king/common.tf
    
    terraform {
      backend "s3" {
        bucket  = "<<< YOUR REMOTE STATE S3 BUCKET NAME >>>"
        key     = "king-vpn/terraform.tfstate"
        region  = "ap-northeast-1"
        encrypt = "true"
      }
    }
    ```
    
3.  ```
    $ terraform init
    $ terraform apply
    ```
    
4. 생성될 resource들을 확인한 후 yes를 입력합니다.

    ![](https://github.com/devsisters/king-openvpn/blob/vpc-peering/screenshots/terraform_apply.png?raw=true)
    
5. AWS 콘솔에서 OpenVPN instance의 public ip를 확인한 뒤(예를 들면 13.113.104.76) 브라우저에서 `https://13.113.104.76` 으로 접속합니다.

    ![](https://github.com/devsisters/king-openvpn/blob/vpc-peering/screenshots/openvpn1.png?raw=true)
    
6. Username은 `openvpn`, password는 1에서 넣은 것으로 로그인하면 OpenVPN Connect를 다운받을 수 있습니다.

    ![](https://github.com/devsisters/king-openvpn/blob/vpc-peering/screenshots/openvpn2.png?raw=true)
    
7. OpenVPN Connect 설치/실행 후에 13.113.104.76로 연결합니다.

    ![](https://github.com/devsisters/king-openvpn/blob/vpc-peering/screenshots/openvpn3.png?raw=true)
    
    ![](https://github.com/devsisters/king-openvpn/blob/vpc-peering/screenshots/openvpn4.png?raw=true)
  

