// =========================================================== //

void CreateCommands()
{
	RegAdminCmd("sm_proxykiller_rules_add", Command_RulesAdd, ADMFLAG_ROOT, "Adds an expression to ProxyKiller Rules");
	RegAdminCmd("sm_proxykiller_rules_delete", Command_RulesDelete, ADMFLAG_ROOT, "Deletes an expression from ProxyKiller Rules");

	RegAdminCmd("sm_proxykiller_apply_migration", Command_ApplyMigration, ADMFLAG_ROOT, "Applies a migration to ProxyKiller");
}

// =========================================================== //

public Action Command_RulesAdd(int client, int args)
{
	if (args <= 0)
	{
		ReplyToCommand(client, "Usage: sm_proxykiller_rules_add <expression>");
		return Plugin_Handled;
	}

	char expression[32];
	GetCmdArgString(expression, sizeof(expression));

	TrimString(expression);
	StripQuotes(expression);

	TryPushRule(expression);
	return Plugin_Handled;
}

public Action Command_RulesDelete(int client, int args)
{
	if (args <= 0)
	{
		ReplyToCommand(client, "Usage: sm_proxykiller_rules_delete <expression>");
		return Plugin_Handled;
	}

	char expression[32];
	GetCmdArgString(expression, sizeof(expression));

	TrimString(expression);
	StripQuotes(expression);

	TryDeleteRule(expression);
	return Plugin_Handled;
}


public Action Command_ApplyMigration(int client, int args)
{
	if (args <= 0)
	{
		return Plugin_Handled;
	}

	char migration[MAX_MIGRATION_LENGTH];
	GetCmdArg(1, migration, sizeof(migration));
	MigrationResult result = ApplyMigration(migration);

	switch (result)
	{
		case Result_LookupFailure:
		{
			g_Logger.ErrorMessage("Failed to lookup migration by name \"%s\"", migration);
			ReplyToCommand(client, "Failed to lookup migration by name \"%s\"", migration);
		}
		case Result_ProviderMismatch:
		{
			g_Logger.ErrorMessage("Failed to apply migration \"%s\" as providers mismatch", migration);
			ReplyToCommand(client, "Failed to apply migration \"%s\" as providers mismatch", migration);
		}
	}

	return Plugin_Handled;
}

// =========================================================== //