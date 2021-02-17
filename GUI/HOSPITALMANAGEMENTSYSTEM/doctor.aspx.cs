using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace HOSPITALMANAGEMENTSYSTEM
{
    public partial class doctor : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Label1.Text = " Welcome " + Session["FullName"] + " ";
        }


        protected void Button1_Click(object sender, EventArgs e)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ToString();
            SqlConnection con = new SqlConnection(connectionString);

            string Appointments = "Select a.AppointmentID,e.FirstName + ' ' + e.LastName as DoctorName, pa.FirstName + ' ' + pa.LastName as PatientName,adr.City + ' ' + adr.State + ' ' + CAST(adr.ZipCode AS varchar) as Doctor_Address,p.Medication,a.Date From Appointment a left join Doctor d on a.DoctorID = d.DoctorID inner join Employee e on e.EmployeeID = d.DoctorID left join Addresses adr on adr.AddressID = e.AddressID left join Prescription p on a.AppointmentID = p.AppointmentID left join Patient pa on pa.PatientID = a.PatientID where d.DoctorID =" + Session["DoctorID"];

            SqlDataAdapter da = new SqlDataAdapter(Appointments, con);

            DataSet ds = new DataSet();
            da.Fill(ds);


            try
            {
                con.Open();
            }
            catch (Exception)
            {
                con.Close();
                return;
                throw;
            }

            
            GridView1.DataSource = ds;
            GridView1.DataBind();
            con.Close();


        }

        protected void Button4_Click(object sender, EventArgs e)
        {
            


                string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ToString();

                SqlConnection con = new SqlConnection(connectionString);
                SqlCommand cmd = new SqlCommand("insertAppointment", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add("@AppointmentID", SqlDbType.Int).Value = TextBox1.Text;
                cmd.Parameters.Add("@DoctorID", SqlDbType.Int).Value = TextBox2.Text;
                cmd.Parameters.Add("@PatientID", SqlDbType.Int).Value = TextBox3.Text;

                String setIdentity = "SET IDENTITY_INSERT Appointment ON";
                SqlCommand exec2 = new SqlCommand(setIdentity, con);
            


                con.Open();
                exec2.ExecuteNonQuery();
              cmd.ExecuteNonQuery();
                con.Close();
           
        }

        protected void TextBox1_TextChanged(object sender, EventArgs e)
        {

        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            int success = 0;
            string sqlstr = "Delete From Appointment Where AppointmentID = '" + TextBox1.Text + "'";

            string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ToString();

            SqlConnection con = new SqlConnection(connectionString);

            SqlDataAdapter da = new SqlDataAdapter(sqlstr, con);

            DataSet ds = new DataSet();
            da.Fill(ds);


            try
            {
                con.Open();
            }
            catch (Exception)
            {
                con.Close();
                return;
                throw;
            }

            SqlCommand exec = new SqlCommand(sqlstr, con);

            try
            {
                int a = exec.ExecuteNonQuery();
                if (a != 1)
                    success = 1;
            }
            catch (Exception)
            {
                throw;
            }
            con.Close();

            if(success == 1)
            {
                Label2.Text = "Appointment Deleted.";
            }
            else
            {
                Label2.Text = "Couldn't Delete Appointment.";
            }

        }

        protected void Button3_Click(object sender, EventArgs e)
        {

            int success = 0;
            string sqlstr = "UPDATE Appointment Set DoctorID = '" + TextBox2.Text + "'" + ",";
            sqlstr = sqlstr + "PatientID = '" + TextBox3.Text + "'";
            sqlstr = sqlstr + "Where AppointmentID = '" + TextBox1.Text + "'";

            string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ToString();

            SqlConnection con = new SqlConnection(connectionString);

            SqlDataAdapter da = new SqlDataAdapter(sqlstr, con);

            DataSet ds = new DataSet();
            da.Fill(ds);


            try
            {
                con.Open();
            }
            catch (Exception)
            {
                con.Close();
                return;
                throw;
            }

            SqlCommand exec = new SqlCommand(sqlstr, con);

            try
            {
                int a = exec.ExecuteNonQuery();
                if (a == 1)
                    success = 1;
            }
            catch (Exception)
            {
                throw;
            }
            con.Close();

            if (success == 1)
            {
                Label2.Text = "Appointment Updated.";
            }
            else
            {
                Label2.Text = "Couldn't Update Appointment.";
            }
        }

        protected void Button5_Click(object sender, EventArgs e)
        {


            string cmd = "exec GetCataractPatients";
            string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ToString();

            SqlConnection con = new SqlConnection(connectionString);

            SqlDataAdapter da = new SqlDataAdapter(cmd, con);

            DataSet ds = new DataSet();
            da.Fill(ds);


            try
            {
                con.Open();
            }
            catch (Exception)
            {
                con.Close();
                return;
                throw;
            }


            GridView2.DataSource = ds;
            GridView2.DataBind();
            con.Close();

        }

        protected void Button6_Click(object sender, EventArgs e)
        {


            string cmd = "select *  from Attending_Nurses";
            string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ToString();

            SqlConnection con = new SqlConnection(connectionString);

            SqlDataAdapter da = new SqlDataAdapter(cmd, con);

            DataSet ds = new DataSet();
            da.Fill(ds);


            try
            {
                con.Open();
            }
            catch (Exception)
            {
                con.Close();
                return;
                throw;
            }


            GridView3.DataSource = ds;
            GridView3.DataBind();
            con.Close();

        }
    }
}