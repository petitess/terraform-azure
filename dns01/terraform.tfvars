dns = {
    "domain.commm" = {
        zonename = "domain.commm"
        arecords = [
            {
            name = "pool"
            ttl = 900
            records = ["126.148.65.22", "126.148.65.23"]
            },
            {
            name = "site"
            ttl = 900
            records = ["26.148.65.22"]
            }
        ]
        aaaa = [
            {
            name = "pool"
            ttl = 900
            records = ["FE80:CD00:0000:0CDE:1257:0000:211E:729C", "FE80:CD00:0000:0CDE:1257:0000:211E:985C"]
            },
            {
            name = "site"
            ttl = 900
            records = ["FE80:CD00:0000:0CDE:1257:0000:211E:729C"]
            }
        ]
        caa = [
            {
            name = "info"
            ttl = 900
            record = [
               {
                flags = 0
                tag = "issue"
                value = "sectigo.com"
                
                },
                {
                flags = 1
                tag = "issue"
                value = "sectigo.net"
                
                }
            ]
            },
            {
            name = "page"
            ttl = 900
            record = [
               {
                flags = 0
                tag = "issue"
                value = "sectigo.com"
                
                }
            ]
            }
        ]
        cname = [
            {
            name = "selector1._domainkey"
            ttl = 900
            record = "selector1-xxxxx-se._domainkey.xx.onmicrosoft.com"
            },
            {
            name = "selector2._domainkey"
            ttl = 900
            record = "selector2-xxxxx-se._domainkey.xx.onmicrosoft.com"
            }
        ]
        mx = [
            {
            name = "@"
            ttl = 900
            record = [
               {
                preference = 0
                exchange = "xxxx-se.mail.protection.outlook.com"
                },
                {
                preference = 0
                exchange = "yyy-se.mail.protection.outlook.com"
                }
            ]
            },
            {
            name = "blekinge"
            ttl = 900
            record = [
               {
                preference = 0
                exchange = "xxx-smtp.wineasy.se."
                }
            ]
            }
        ]
        ns = [
            {
            name = "dns"
            ttl = 172800
            record = ["ns5-03.azure-dns.com"]
            }
        ]
        ptr = [
            {
            name = "dl"
            ttl = 900
            record = ["youtube.com"]
            },
            {
            name = "el"
            ttl = 900
            record = ["rumble.com"]
            },
        ]
        srv = [
            {
            name = "info"
            ttl = 86400
            record = [
               {
                port = 5223
                priority = 10
                target = "server.example.com"
                weight = 5
                
                }
            ]
            }
        ]
        txt = [
            {
            name = "608._domainkey"
            ttl = 900
            record = [
               {
                value = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDGoQCNwAQdJBy23MrShs1EuHx;"
                }
            ]
            },
            {
            name = "effekt"
            ttl = 900
            record = [
               {
                value = "v=spf1 include:_xxx.xxxxxx.com include:spf.protection.outlook.com ~all."
                }
            ]
            }
        ]
    }
    "domain.cnet" = {
        zonename = "domain.cnet"
        arecords = [
            {
            name = "pool"
            ttl = 900
            records = ["126.148.65.22", "126.148.65.23"]
            },
            {
            name = "site"
            ttl = 900
            records = ["26.148.65.22"]
            }
        ]
        aaaa = [
            {
            name = "pool"
            ttl = 900
            records = ["FE80:CD00:0000:0CDE:1257:0000:211E:729C", "FE80:CD00:0000:0CDE:1257:0000:211E:985C"]
            },
            {
            name = "site"
            ttl = 900
            records = ["FE80:CD00:0000:0CDE:1257:0000:211E:729C"]
            }
        ]
        caa = [
            {
            name = "info"
            ttl = 900
            record = [
               {
                flags = 0
                tag = "issue"
                value = "sectigo.com"
                
                },
                {
                flags = 1
                tag = "issue"
                value = "sectigo.net"
                
                }
            ]
            },
            {
            name = "page"
            ttl = 900
            record = [
               {
                flags = 0
                tag = "issue"
                value = "sectigo.com"
                
                }
            ]
            }
        ]
        cname = [
            {
            name = "selector1._domainkey"
            ttl = 900
            record = "selector1-xxxxx-se._domainkey.xx.onmicrosoft.com"
            },
            {
            name = "selector2._domainkey"
            ttl = 900
            record = "selector2-xxxxx-se._domainkey.xx.onmicrosoft.com"
            }
        ]
        mx = []
        ns = []
        ptr = []
        srv = []
        txt = []
    }
}
