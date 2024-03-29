
lane :rsb_start_ticket do |options|
  ensure_git_status_clean
  ticket_key = options[:key]
  tickets = rsb_search_jira_tickets(
    statuses: [rsb_jira_status[:to_do], rsb_jira_status[:doing]]
  )
  UI.user_error!("There are no tickets in #{rsb_jira_status[:to_do][:name]} and #{rsb_jira_status[:doing][:name]}") if tickets.empty?
  start_tickets = rsb_select_jira_tickets_with_statuses(tickets, [rsb_jira_status[:to_do]])
  ticket = rsb_select_jira_ticket_with_key(start_tickets, ticket_key) if ticket_key
  ticket = rsb_select_jira_ticket_with_dialog(start_tickets, "Select the ticket you want to start") unless ticket
  doing_tickets = rsb_select_jira_tickets_assigned_to_me(rsb_select_jira_tickets_with_statuses(tickets, [rsb_jira_status[:doing]]))
  if rsb_is_bug_jira(ticket)
    rsb_start_hotfix_branch(
      name: rsb_hotfix_branch_name(ticket)
    )
  else
    rsb_start_feature_branch(
      name: rsb_feature_branch_name(ticket)
    )
  end
  rsb_move_jira_tickets(
  	tickets: doing_tickets,
  	transition: rsb_jira_transition[:to_do]
  ) unless doing_tickets.empty?
  rsb_move_jira_tickets(
    tickets: [ticket],
    transition: rsb_jira_transition[:doing]
  )
end

lane :rsb_code_review_ticket do
  ensure_git_status_clean
  tickets = rsb_search_jira_tickets(
    statuses: [rsb_jira_status[:doing]],
    mine: true,
    task: true
  )
  if tickets.empty?
    UI.error("Can not find tasks assigned to you in #{rsb_jira_status[:doing][:name]}")
    tickets = rsb_search_jira_tickets(
      statuses: [rsb_jira_status[:doing]],
      mine: false,
      task: true
    )
  end
  ticket = rsb_select_jira_ticket_with_dialog(tickets, "Select the ticket for code review")
  branch_name = rsb_search_feature_branch_name(ticket)
  UI.user_error!("Can not find feature branch name for ticket #{ticket.key}") if !branch_name
  rsb_push_feature_branch(
    name: branch_name
  )
  rsb_move_jira_tickets(
    tickets: [ticket],
    transition: rsb_jira_transition[:code_review]
  )
  github = 'https://github.com/'
  origin = sh('git config --get remote.origin.url | tr -d \'\n\'').gsub('git@github.com:', github).gsub('.git','')
  if origin.include? github
    code_review_url = "#{origin}/compare/develop...feature/#{branch_name}?expand=1"
    sh("open #{code_review_url}")
  end
end

lane :rsb_finish_ticket do |options|
  ensure_git_status_clean
  ticket_key = options[:key]
  tickets = rsb_search_jira_tickets(
    statuses: [rsb_jira_status[:doing], rsb_jira_status[:code_review]],
    mine: true
  )
  UI.user_error!("There are no tickets in #{rsb_jira_status[:doing][:name]} and #{rsb_jira_status[:code_review][:name]} assigned to you") if tickets.empty?
  if ticket_key
    ticket = rsb_select_jira_ticket_with_key(tickets, ticket_key)
    UI.user_error!("You are trying to finish ticket that is not assigned to you") unless ticket
  else
    ticket = rsb_select_jira_ticket_with_dialog(tickets, "Select the ticket you want to finish")
  end
  if rsb_is_bug_jira(ticket)
    wontdo = options[:wontdo]
    if wontdo
      rsb_delete_hotfix_branch(
        name: rsb_hotfix_branch_name(ticket)
      )
      rsb_move_jira_tickets(
        tickets: [ticket],
        transition: rsb_jira_transition[:wont_do]
      )
    else
      rsb_finish_hotfix_branch(
        name: rsb_hotfix_branch_name(ticket)
      )
      rsb_move_jira_tickets(
        tickets: [ticket],
        transition: rsb_jira_transition[:ready]
      )
    end
  else
    branch_name = rsb_search_feature_branch_name(ticket)
    UI.user_error!("Can not find feature branch name for ticket #{ticket.key}") if !branch_name
    rsb_finish_feature_branch(
      name: branch_name
    )
    rsb_move_jira_tickets(
      tickets: [ticket],
      transition: rsb_jira_transition[:ready]
    )
  end
end
