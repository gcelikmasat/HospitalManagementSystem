using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
//
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace HOSPITALMANAGEMENTSYSTEM
{
    public class DBConnection
    {
        String connectionString;
        SqlConnection con;
        public DBConnection()
        {
            connectionString = ConfigurationManager.ConnectionStrings["conStr"].ToString();
            con = new SqlConnection(connectionString);
        }

        public DataSet getSelect(string sqlstr)
        {
            try
            {
                con.Open();
            }
            catch (Exception)
            {
                con.Close();
                throw;
            }

            DataSet ds = new DataSet();
            SqlDataAdapter da = new SqlDataAdapter(sqlstr, connectionString);
            da.Fill(ds);
            con.Close();
            return ds;
        }
        public bool execute(string sqlstr)
        {
            try
            {
                con.Open();
            }
            catch (Exception)
            {
                con.Close();
                return false;
                throw;
            }

            try
            {
                SqlCommand exec = new SqlCommand(sqlstr, con);
                exec.ExecuteNonQuery();
                con.Close();
            }
            catch (Exception)
            {
                return false;
                throw;
            }
            return true;

        }

    }
}