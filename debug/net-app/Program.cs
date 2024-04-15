using System;
using System.Net.Security;
using System.Net.Sockets;
using System.Security.Authentication;
using System.Security.Cryptography.X509Certificates;
using System.Text;

namespace net_app
{
    class Program
    {
        // server
        private static string ServerIp = "192.168.1.187"; // localhost
        private static int ServerPort = 60002;

        // certificate
        private static string ServerCertName = "192.168.1.187";
        private static string ClientCertFile = @"C:\Data\certs\certdata_ip_20240412100735\public.pfx";
        private static string ClientCertPassword = "1";


        static void Main(string[] args)
        {
            try
            {
                // create X506 cert collecion
                var clientCert = new X509Certificate2(ClientCertFile, ClientCertPassword);
                var clientCertCollection = new X509CertificateCollection(new X509Certificate[] { clientCert });

                Console.WriteLine("try connect to server");

                // tcp / ssl Client
                using (var tcpClient = new TcpClient(ServerIp, ServerPort))
                using (var sslStream = new SslStream(tcpClient.GetStream(), false, CertificateValidationCallback))
                {
                    Console.WriteLine("tcp layer client connnected");
                    Console.WriteLine("sslstream authenticate client");

                    sslStream.AuthenticateAsClient(ServerCertName, clientCertCollection, SslProtocols.Tls12, false);

                    // write data
                    var txData = "Hello World";
                    var txBuffer = Encoding.UTF8.GetBytes(txData);
                    sslStream.Write(txBuffer);

                    //read data
                    var rxBuffer = new byte[256];
                    var rxLength = 0;
                    while (rxLength == 0)
                    {
                        rxLength = sslStream.Read(rxBuffer, 0, rxBuffer.Length);
                    }
                    var rxData = Encoding.UTF8.GetString(rxBuffer, 0, rxLength);
                    Console.WriteLine(rxData);

                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("exception name {0}", ex.GetType().Name, ex.Message);
                Console.WriteLine("exception message {1}", ex.Message);
            }
        }


        private static bool CertificateValidationCallback(Object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
        {
            if (sslPolicyErrors == SslPolicyErrors.None) { return true; }
            if (sslPolicyErrors == SslPolicyErrors.RemoteCertificateChainErrors) { return true; }
            Console.WriteLine("ssl error: " + sslPolicyErrors.ToString());
            return false;
        }
    }
}
