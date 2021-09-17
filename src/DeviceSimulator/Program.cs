using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Azure.Devices.Client;

namespace DeviceSimulator
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var fileName = args.Length > 0 ? args[0] : "devices.txt";
            Console.Write($"Loading devices from {fileName}... ");
            var devices = File.ReadAllLines(fileName);
            Console.WriteLine($"got {devices.Length} device(s)");

            var tokenSource = new CancellationTokenSource();
            Console.CancelKeyPress += (object sender, ConsoleCancelEventArgs args) => 
            {
                args.Cancel = true;
                tokenSource.Cancel();
            };

            Console.WriteLine("Starting to send messages, use Ctrl+C to stop...");
            var sendingTasks = devices.Select(device => SendMessages(device, tokenSource.Token));

            try
            {
                await Task.WhenAll(sendingTasks);
            }
            catch (TaskCanceledException)
            {
                // this is expected
            }

            Console.WriteLine("Exiting.");
        }

        static async Task SendMessages(string deviceConnectionString, CancellationToken cancellationToken)
        {
            var random = new Random();
            var deviceId = deviceConnectionString.Split(';').Select(x => x.Split('=')).ToDictionary(x => x[0], x => x[1])["DeviceId"];
            Console.WriteLine($"{deviceId} is starting...");

            using var deviceClient = DeviceClient.CreateFromConnectionString(deviceConnectionString, TransportType.Mqtt);

            while (!cancellationToken.IsCancellationRequested)
            {
                var value = random.NextDouble();
                var payload = new Payload { Value = value };
                var json = JsonSerializer.Serialize(payload);
                Console.WriteLine($"{deviceId} is sending '{json}'");

                var message = new Message(Encoding.UTF8.GetBytes(json))
                {
                    ContentType = "application/json",
                    ContentEncoding = "utf-8"
                };

                await deviceClient.SendEventAsync(message, cancellationToken);

                var delayMs = random.Next(360, 3600);
                await Task.Delay(delayMs, cancellationToken);
            }
        }

        class Payload
        {
            public double Value { get; set; }
        }
    }
}
