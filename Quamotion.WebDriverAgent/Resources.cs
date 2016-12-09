using System;
using System.IO;
using System.Reflection;

namespace Quamotion.WebDriverAgent
{
    public static class Resources
    {

        public static Stream WebDriverAgent
        {
            get
            {
                string name = $"Quamotion.WebDriverAgent.WebDriverAgent.zip";
                return typeof(Resources).GetTypeInfo().Assembly.GetManifestResourceStream(name);
            }
        }
    }
}
