using System;
using System.Threading.Tasks;

namespace Receiver
{
    class Program
    {
        public static async Task<int> Main(string[] args)
        {
            Console.WriteLine("Receiver start running");

            await Task.Delay(TimeSpan.FromHours(1));

            return 0;
        }
    }
}
