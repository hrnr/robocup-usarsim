using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace USARSimMetricTool.USARSim
{
    public class USARItems
    {
        public List<USARItem> items = new List<USARItem>();
        public void parse(string command)
        {
            string[] itemsCommand = command.Split("\n".ToCharArray());
            int count = itemsCommand.Length;
            for (int i = 0; i < count; i++)
            {
                if (!string.IsNullOrEmpty(itemsCommand[i]))
                {
                    USARItem item = new USARItem();
                    if (item.parse(itemsCommand[i]))
                        items.Add(item);
                }
            }
        }
    }
}
