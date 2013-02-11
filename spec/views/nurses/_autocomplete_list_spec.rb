require 'spec_helper'






describe 'nurses/_autocomplete_list' do
  it 'renders' do
    render
  end
  it 'renders corrct list of procedures' do
    render
    eval("[ #{rendered} ].size").should == Procedure.count
  end
  it 'correctly renders procedures with html unfriendly names' do
    unfriendly_name = '+++++&&&&&'
    Fabricate :procedure, name: unfriendly_name
    render
    rendered.should include unfriendly_name
  end
end