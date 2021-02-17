using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
// 
using System.Configuration;
using System.Data;
using System.Data.SqlClient;


namespace HOSPITALMANAGEMENTSYSTEM
{
    public partial class default2 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["conStr"].ToString();

            SqlConnection con = new SqlConnection(connectionString);

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

            DataSet ds = new DataSet();
            string doctorInfo = "";

            doctorInfo = "Select  d.DoctorID, d.Password, (e.FirstName +' '+ e.LastName) FullName, e.Age, e.Gender from dbo.Doctor d left join Employee e on e.EmployeeID=d.DoctorID Where d.DoctorID = " + TextBox1.Text;

            SqlDataAdapter da = new SqlDataAdapter(doctorInfo, con);
            da.Fill(ds);


            string DoctorID = ds.Tables[0].Rows[0]["DoctorID"].ToString();
            string password = ds.Tables[0].Rows[0]["Password"].ToString();
            string FullName = ds.Tables[0].Rows[0]["FullName"].ToString();
            string Age = ds.Tables[0].Rows[0]["Age"].ToString();
            string Gender = ds.Tables[0].Rows[0]["Gender"].ToString();
            string enteredPassword = TextBox2.Text;
            Console.WriteLine(password);
            con.Close();

            Session["DoctorID"] = DoctorID;
            Session["FullName"] = FullName;
            Session["Age"] = Age;
            Session["Gender"] = Gender;

            if (String.Equals(password, enteredPassword))
                Response.Redirect("doctor.aspx");
            else
            {
                Label1.Text = "Invalid Password!";
                Response.AddHeader("REFRESH", "2;URL=default.aspx");
            }

        }
    }
}