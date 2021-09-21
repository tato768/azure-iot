using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Azure.Devices.Client;

namespace DeviceSimulator
{
    partial class Program
    {
        static async Task Main(string[] args)
        {
            var deviceFile = args.FirstOrDefault();

            if (!DeviceFileExists(deviceFile))
            {
                Console.WriteLine("Usage: DeviceSimulator.exe <path to file with device connection strings>");
                return;
            }

            Console.Write($"Loading devices from {deviceFile}... ");
            var devices = await GetDevices(deviceFile);
            Console.WriteLine($"got {devices.Count} device(s)");

            var tokenSource = new CancellationTokenSource();
            Console.WriteLine("Starting to send messages, use ENTER to stop...");
            var sendingTasks = devices.Select(device => SendMessages(device, tokenSource.Token)).ToList();

            Console.ReadLine();
            Console.WriteLine("Stopping all tasks...");
            tokenSource.Cancel();

            try 
            {
                await Task.WhenAll(sendingTasks);
            }
            catch (TaskCanceledException)
            {
                // this is expected
            }

            // this is emberassing but the application keeps hanging
            Console.WriteLine("Exiting, if the application doesn't stop in a timely fasion please use Ctrl+C.");
        }

        private static bool DeviceFileExists(string deviceFile)
        {
            return !string.IsNullOrEmpty(deviceFile)
                && File.Exists(deviceFile);
        }

        private static async Task<List<Device>> GetDevices(string deviceFile)
        {
            var json = await File.ReadAllTextAsync(deviceFile);
            var devices = JsonSerializer.Deserialize<List<Device>>(json);
            return devices;
        }

        static async Task SendMessages(Device device, CancellationToken cancellationToken)
        {
            var random = new Random();
            Console.WriteLine($"{device.DeviceId} is starting...");

            using var deviceClient = DeviceClient.CreateFromConnectionString(device.ConnectionString, TransportType.Mqtt);

            while (!cancellationToken.IsCancellationRequested)
            {
                var value = random.NextDouble();
                var payload = new Payload { Value = value };
                var json = JsonSerializer.Serialize(payload);
                Console.WriteLine($"{device.DeviceId} is sending '{json}'");

                using var message = new Message(Encoding.UTF8.GetBytes(json))
                {
                    ContentType = "application/json",
                    ContentEncoding = "utf-8"
                };

                await deviceClient.SendEventAsync(message, cancellationToken);

                var delayMs = random.Next(360, 3600);
                await Task.Delay(delayMs, cancellationToken);
            }
        }
    }
}
