using System;
using System.IO;
using System.Reactive.Linq;
using System.Threading.Tasks;

namespace Sender
{
    public class Program
    {
        public static async Task<int> Main(string[] args)
        {
            Console.WriteLine("Sender start running");

            var stream = new FileStream("log-output.log", FileMode.Create, FileAccess.Write, FileShare.ReadWrite);

            var writer = new StreamWriter(stream);

            Observable.Interval(TimeSpan.FromMilliseconds(100))
                      .Subscribe(
                        (result) =>
                        {
                            writer.WriteLine($"[{DateTimeOffset.Now.ToString("HH:mm:ss.fff")}]   {result}");
                            writer.Flush();
                        },
                        (error) =>
                        {
                            writer.WriteLine($"[{DateTimeOffset.Now.ToString("HH:mm:ss.fff")}]  Error occurred {error}");
                            writer.Flush();
                        },
                        () => {
                            writer.WriteLine($"[{DateTimeOffset.Now.ToString("HH:mm:ss.fff")}]  complete");
                            writer.Flush();

                            writer.Close();
                            writer.Dispose();
                        });


            await Task.Delay(TimeSpan.FromHours(1));

            return 0;
        }
    }
}
