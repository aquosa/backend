// DBConnection.h
#pragma once

#include <windows.h>  
#include <sqlext.h>  
#include <mbstring.h>  
#include <stdio.h>  

#define MAX_DATA 100  
#define MYSQLSUCCESS(rc) ((rc == SQL_SUCCESS) || (rc == SQL_SUCCESS_WITH_INFO) )  

using namespace System;

class DBConnection
{
	private:
		RETCODE rc; // ODBC return code  
		HENV henv; // Environment     
		HDBC hdbc; // Connection handle  
		HSTMT hstmt; // Statement handle  

		unsigned char szData[MAX_DATA]; // Returned data storage  
		SDWORD cbData; // Output length of data  
		unsigned char chr_ds_name[SQL_MAX_DSN_LENGTH]; // Data source name  

	public:  
		DBConnection::DBConnection(); // Constructor  
		void DBConnection::sqlconn(); // Allocate env, stat, and conn  
		void DBConnection::sqlexec(unsigned char *); // Execute SQL statement  
		void DBConnection::sqldisconn(); // Free pointers to env, stat, conn, and disconnect  
		void DBConnection::error_out(); // Displays errors  
};

