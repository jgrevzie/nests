require 'spec_helper'



describe 'completed_procs/_autocomplete_list' do
  it 'renders correct list of procedures' do
    dept1 = Fabricate :dept, name: 'Mail Dept'
    dept2 = Fabricate :dept, name: 'Microwave Ovens'
    Fabricate :proc, name: 'Lick Stamp', dept: dept1
    Fabricate :proc, name: 'Open Stampbook', dept: dept1

    Fabricate :proc, name: 'Cook Rice', dept: dept2
    render template: _default_file_to_render, locals: {nurse: Fabricate(:nurse, dept: dept1)}
    eval("#{rendered}.size").should == 2
  end
  it 'correctly renders procedures with html unfriendly names' do
    unfriendly_name = '+++++&&&&&'
    p = Fabricate :procedure, name: unfriendly_name
    render template: _default_file_to_render, locals: {nurse: Fabricate(:nurse, dept: p.dept)}
    rendered.should include unfriendly_name
  end
end
